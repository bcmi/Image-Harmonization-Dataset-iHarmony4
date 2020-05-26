%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% evalIFGT  Evaluate the density estimate using the "improved" Fast Gauss Transform
%
%   [e,b] = evalIFGT(X,Y,N [,Nc,rC]) -- eval likelihood ("e") of the points Y under
%                       the density estimate X using N coefficients of the
%                       "improved" Fast Gauss Transform; the value "b" is the bound
%                       on the (absolute) error which could arise.
%
%  Optional arguments:
%    Nc  -- # of clusters to use for "X", default is sqrt(Npoints) 
%    rC  -- Cutoff radius (in std deviations) to exclude contributions, default 3
%
% See: Yang, Duraiswami, Gumerov; "Improved Fast Gauss Transform", submitted to 
%         the Siam Journal of Scientific Computing, 2004
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [estimate,errbound] = evalIFGT(pp,q,Ncoeff,Nclusters,rCutoff)
  p = kde(pp);	% copy constructor to dodge later rescaling...
  if (p.type ~= 0)  
    error('Sorry -- FGT = fast Gauss transform; it needs Gaussian kernels');
  end;
  if (size(p.bandwidth,2)>2*p.N)
    error('Sorry -- IFGT currently supports only uniform bandwidths');
  end;
  if (nargin<4) Nclusters = round(sqrt(getNpts(p))); end;
  if (nargin<5) rCutoff = 3; end;  
  if (isa(q,'kde')) qpts = getPoints(q); else qpts = q; end;
  
  BW = getBW(p,1); BWorig = BW;
  if (any( BW - BW(1) ))   % CONVERT TO SINGLE, SCALAR BW:
    p = rescale(p, 1./BW); %  if differ in dimensions, need to rescale
    qpts = qpts .* repmat(1./BW,[1,size(qpts,2)]);
    BW = 1;
  else BW = BW(1);         % already scalar; can just drop other dim's
  end;

  [c,cPts,cWts,cWt,cRad] = fpClusterK(p,Nclusters);
  %[c,cPts,cWts,cWt,cRad] = fpClusterR(p,sqrt(2)*BW);
  coeff = findCoeff(c,cPts,cWts,cRad,BW,Ncoeff);
  [estimate,errbound] = evalCoeff( qpts, c,coeff,Ncoeff,cWt,BW,cRad,rCutoff);

  % Change norm. constant (due to rescaling operation)
  scale = p.D*log(BW) - sum(log(BWorig));
  estimate = estimate * exp(scale); errbound = errbound * exp(scale);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fpCluster -- fast, "farthest point" clustering method
%   cluster points of "p" into K clusters, described by "centers",
%    "clusters" (cell array of pts to each cluster),
%    cWeight (weight per cluster), and maximum radius of any cluster.
%
function [centers, clusters, weights, cWeight, radius] = fpClusterK(p, K)
  points = getPoints(p); wts = getWeights(p);
  [D,N] = size(points);
  centers = zeros(D,K); clusters = cell(1,K); weights = cell(1,K);
  assign = ones(1,N); dmin = zeros(1,N)+inf;
  next = fix(rand(1)*N)+1;  % choose 1st center at random
  for i=1:K
    centers(:,i) = points(:, next);
    d = points - repmat(centers(:,i),[1,N]);
    d = sqrt(sum(d.^2,1));
    F=find(d<dmin); dmin(F)=d(F); assign(F) = i;
    [radius, next] = max(dmin); % next center is a farthest point
  end;
  cWeight = zeros(1,K);
  for i=1:K
    clusters{i}=points(:, find(assign == i) );
    weights{i}=wts(:, find(assign == i) );
    cWeight(i) = sum(weights{i}); %size(clusters{i},2) / N;
  end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Same thing but cluster until radius < rMax
function [centers, clusters, weights, cWeight, radius] = fpClusterR(p, rMax)
  points = getPoints(p); wts = getWeights(p);
  [D,N] = size(points); K = N; centers = zeros(D,K);
  assign = ones(1,N); dmin = zeros(1,N)+inf;
  next = fix(rand(1)*N)+1;  % choose 1st center at random
  i=0; radius = inf;
  while (radius > rMax),
    i=i+1; centers(:,i) = points(:, next);
    d = points - repmat(centers(:,i),[1,N]);
    d = sqrt(sum(d.^2,1));
    F=find(d<dmin); dmin(F)=d(F); assign(F) = i;
    [radius, next] = max(dmin); % next center is a farthest point
  end;
  K=i; centers = centers(:,1:K);
  cWeight = zeros(1,K); clusters = cell(1,K); weights = cell(1,K);
  for i=1:K
    clusters{i}=points(:, find(assign == i) );
    weights{i}=wts(:, find(assign == i) );
    cWeight(i) = sum(weights{i}); %size(clusters{i},2) / N;
  end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% findCoeff -- find the Taylor series coefficients of the Gaussian sum
%   described by each cluster.
%
function coeff = findCoeff(centers, points, weights, radius, h, Nterms)
  h = sqrt(2)*h;        % stupid transform...

  Npart = length(points); coeff = cell(1,Npart); D = size(centers,1);
  NptsTotal = 0;
  Npts = zeros(1,Npart); for i=1:Npart, Npts(i) = size(points{i},2); end;
  NptsTotal = sum(Npts);

  for i=1:Npart
    NptsI = Npts(i);
    vals = ( points{i}-repmat(centers(:,i),[1,NptsI]) )/h;

    Ncoeff = round(exp( sum(log(Nterms:Nterms+D-1))-sum(log(1:Nterms)) ));
    coeffI = zeros(NptsI, Ncoeff);

    start = 0; startNew = 1;
    coeffI(:, start+1) = exp( -sum(vals.^2,1) )';
    pos = ones(1,D); alpha = zeros(D,1);

    for j=2:Nterms
      Nprev = startNew - start;
      Nadd = sum(Nprev-pos+1); alphaNew = zeros(D,Nadd);
      m = 1; posNew(1) = m;
      for k=1:D
        for l=pos(k):Nprev
          alphaNew(:,m) = alpha(:,l); alphaNew(k,m) = alphaNew(k,m)+1;
          constFactor = 2  ./ prod(max(alphaNew(:,m),1));
          coeffI(:,startNew+m) = vals(k,:)' .* coeffI(:,start+l) * constFactor;
          m = m+1;
        end;
        if (k ~= D) posNew(k+1) = m; end;
      end;
      pos = posNew; alpha = alphaNew; start = startNew; startNew = start+Nadd;
    end;
    %coeffI = sum(coeffI,1)/NptsTotal;
    coeffI = weights{i}*coeffI;
    coeff{i} = coeffI;
  end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% evalCoeff -- evaluate the Taylor series at a number of new locations
%   also returns an upper bound on the incurred error
%
function [est, err] = evalCoeff(locations,centers,coeff,Nterms,cWt,h,cRad,rCutoff)

  h = sqrt(2)*h;	% stupid transformation

  Npts = size(locations,2); Npart = size(centers,2); D = size(locations,1);
  est = zeros(1,Npts);
  err = zeros(1,Npts);
  for i=1:Npart  
      coeffI = coeff{i};
      vals = ( locations - repmat(centers(:,i),[1,Npts]) ) / h;
      distance2 = sum(vals.^2,1);
      PTS = find( distance2 < rCutoff^2);
      PTSN = find( distance2 >= rCutoff^2);

      start = 0; startNew = 1;
      terms = zeros(length(PTS),size(coeffI,2));
      terms(:,start+1) = exp( - distance2(PTS) )';
      pos = ones(1,D); 
      for j=2:Nterms
        Nprev = startNew - start;
	Nadd = sum(Nprev-pos+1); 
	m=1; posNew(1)=m;
	for k=1:D
	  for l=pos(k):Nprev
	    terms(:,startNew+m) = vals(k,PTS)' .* terms(:,start+l);
	    m = m+1;
	  end;
	  if (k~=D) posNew(k+1) = m; end;
	end;
	pos = posNew; start = startNew; startNew = start+Nadd;
      end;
      est(PTS) = est(PTS) + (coeffI * terms');

      % error bound addition for included points...  + Qin * 2^p/p! rhox^p rhoy^p
      err(PTS)=err(PTS) + cWt(i)*exp( Nterms*log(2*rCutoff)- sum(log(1:Nterms)) + Nterms*log(cRad/h) );

      % error bound addition for excluded points...  + Qin * exp(-rhoy^2+rhox^2)
      err(PTSN)=err(PTSN) + cWt(i)*exp( - rCutoff^2 + (cRad/h)^2 );

 end; 
 h = h / sqrt(2);
 
 est = est ./ (2*pi*h^2)^(D/2);
 err = err ./ (2*pi*h^2)^(D/2);

