%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% evalIFGT  Evaluate the density estimate using the (original) Fast Gauss Transform
%
%   [e,b] = evalFGT(X,Y,N [,Nc,rC]) -- eval likelihood ("e") of the points Y under
%                       the density estimate X using N coefficients of the
%                       Fast Gauss Transform (Hermite polynomial expansion); 
%                       "b" is an upper bound on the (absolute) error.
%
%  Optional arguments:
%    Nc  -- # of clusters to use for "X", default is sqrt(Npoints) 
%    rC  -- Cutoff radius (in std deviations) to exclude contributions, default 3
%
% CITATION: Greengard & Strain, 1991, SIAM J. Sci. Stat. Comput. 12
% NOTE: The error bound of G&S'91 is incorrect; we use that of Baxter & Roussos 2002
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [estimate,errbound] = evalFGT(pt,q,Ncoeff,Nclusters,rCutoff)
  p = kde(pt);
  if (p.type ~= 0)  
    error('Sorry -- FGT = fast Gauss transform; it needs Gaussian kernels');
  end;
  if (size(p.bandwidth,2)>2*p.N)
    error('Sorry -- FGT currently supports only uniform bandwidths');
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

  [c,cPts,cWts,cWt,cRad] = fpCluster(p,sqrt(2)*BW);
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
function [centers, clusters, weights, cWeight, radius] = fpCluster(p, rMax)
  points = getPoints(p); wts = getWeights(p);
  [D,N] = size(points);
  K = N;
  centers = zeros(D,K); 
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
% findCoeff -- find the Hermite series coefficients of the Gaussian sum
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
    vals = ( points{i}-repmat(centers(:,i),[1,NptsI]) )'/h;
    Ncoeff = Nterms^D;
    coeffI = zeros(NptsI, Ncoeff);
    coeffTMP = zeros(NptsI,D,Nterms);

    coeffTMP(:,:,1) = 1;
    for j=2:Nterms
      coeffTMP(:,:,j) = coeffTMP(:,:,j-1) .* vals ./ (j-1);
    end;
    indA = ones(1,D); indB = 1;
    while (indB<=Ncoeff)                 % Compute p^D terms...
      coeffI(:,indB) = coeffTMP(:,1,indA(1));
      for j=2:D, coeffI(:,indB) = coeffI(:,indB) .* coeffTMP(:,j,indA(j)); end;
      indB = indB+1; indA(1)=indA(1)+1;  % Increment position index
      for j=1:D-1, if (indA(j)>Nterms), indA(j)=1; indA(j+1)=indA(j+1)+1; end; end;
    end;
    coeffI = weights{i}*coeffI;
    coeff{i} = coeffI;
  end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% evalCoeff -- evaluate the Taylor series at a number of new locations
%   also returns an upper bound on the incurred error
%
function [est, err] = evalCoeff(locations,centers,coeff,Nterms,cWt,h,cRad,rCutoff)

  h = sqrt(2)*h;	% stupid transformation
  rCutoff = sqrt(2)*rCutoff;

  Npts = size(locations,2); Npart = size(centers,2); D = size(locations,1);
  est = zeros(1,Npts); err = zeros(1,Npts);

  % OLD ERROR BOUND OF GREENGARD & STRAIN
  %errBound = (2.75)^D*(1/factorial(Nterms))^(D/2)*(1/2)^((Nterms+1)*D/2);
  % NEW ERROR BOUND OF BAXTER & ROUSSOS
  errBound = 0;
  for k=0:D-1,
    errBound = errBound + nchoosek(D,k)*(1-.5^(Nterms/2))^k * (.5^Nterms/factorial(Nterms))^((D-k)/2);
  end;
  errBound = errBound/(1 - sqrt(.5)^D);

  for i=1:Npart  
    coeffI = coeff{i}; Ncoeff = size(coeff{i},2);
    vals = ( locations - repmat(centers(:,i),[1,Npts]) )' / h;
    distance2 = sum(vals.^2,2);
    PTS = find( distance2 < rCutoff^2); vals = vals(PTS,:); NptsI = size(PTS,1);
    PTSN = find( distance2 >= rCutoff^2);

    if (NptsI),
      terms = zeros(NptsI,size(coeffI,2)); termsTMP = zeros(NptsI,D,size(coeffI,2));
      termsTMP(:,:,1) = 1;
      termsTMP(:,:,2) = 2 * vals;
      for j=3:Nterms   % Recursively compute hermite polynomials Hn(vals):
        termsTMP(:,:,j) = 2.*vals.*termsTMP(:,:,j-1) - 2.*(j-2).*termsTMP(:,:,j-2);
      end;
      for j=1:Nterms   % Then compute hermite functions: Hn(x) e^(-x^2)
        termsTMP(:,:,j) = termsTMP(:,:,j) .* exp(-vals.^2);
      end;

      indA = ones(1,D); indB = 1;
      while (indB<=Ncoeff)                 % Compute p^D terms...
        terms(:,indB) = termsTMP(:,1,indA(1));
        for j=2:D, terms(:,indB) = terms(:,indB) .* termsTMP(:,j,indA(j)); end;
        indB = indB+1; indA(1)=indA(1)+1;  % Increment position index
        for j=1:D-1, if (indA(j)>Nterms), indA(j)=1; indA(j+1)=indA(j+1)+1; end; end;
      end;

      est(PTS) = est(PTS) + (coeffI * terms');
      % error bound addition for included points...  
      err(PTS)=err(PTS) + cWt(i)*errBound;
    end;
    % error bound addition for excluded points...  + Qin * exp(-rhoy^2+rhox^2)
    err(PTSN)=err(PTSN) + cWt(i)*exp( - rCutoff^2 + (cRad/h)^2 );

 end; 
 h = h / sqrt(2);
 
 est = est ./ (2*pi*h^2)^(D/2);
 err = err ./ (2*pi*h^2)^(D/2);

