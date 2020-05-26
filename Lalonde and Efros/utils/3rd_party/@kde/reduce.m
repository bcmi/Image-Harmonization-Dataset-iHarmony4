function [q,o2,o3] = reduce(p,type,varargin)
%
% q = reduce(p,'type',[options]) --  "Reduce" a KDE, so that it requires fewer 
%   kernels but has similar representative power (better than just resampling)
%
% 'type' is one of:
%     'mscale' -- "Multiscale data condensation" method of Mitra et al. PAMI '02
%                  Selects retained points based on k-nearest-neighbor distances
%           [options] = k (param of k-nn); controls degree of density reduction
%           Notes: Not a very good (fast) implementation, as of yet.
%                  Method does not make use of KDE's bandwidth
%                  Method fails to account for KDEs with non-uniform weights
%
%     'rsde'   -- "Reduced set dens. est" method of Girolami & He PAMI '03
%                   Minimizes an ISE (integrated squared error) criterion by 
%                   solving a QP to induce sparsity among kernel weights.
%           [option1] = QP solution method, one of:
%               'smo'  --  Sequential Minimal Optimization (default)
%               'mult' --  Multiplicative Updating
%               'qp'   --  Standard quadratic programming (Matlab Optim. Toolbox)
%           [option2] = ISE estimate method (default exact eval); see ise.m for more options
%           Notes: The underlying implementation and quadratic solvers are
%                 adapted directly from Chao He and Mark Girolami's code; see 
%                 their website for more detail
%
%    'em'      -- use Expectation-Maximization to find a (diagonal) GM approx
%           [options] = k, the number of mixtures in output
%
%    'grad'    -- Simple K-L gradient ascent on kernel centers, holding kernel
%                 size fixed (chosen using ROT's heuristic).
%           [options] = N, the number of kernel centers to retain
%                       klMethod; see klGrad for options (e.g. 'LLN' or 'ABS')
%
%    'kdtree'  -- KD-tree based reduction method of Ihler et al.
%           [options]  maxCost (double)/maxN (uint32), 
%                      errType = {'maxlog', 'ise', 'kld'}
%
% See also: kde, resample

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

if (nargin < 2) type = 'rsde'; end;
%fprintf('Reducing KDE : %d points => ',getNpts(p));
switch (lower(type))
  case 'rsde', q=reduceRSDE(p,varargin{:});
  case 'grad', q=reduceGrad(p,varargin{:});
  case 'em',   q=reduceEM(p,varargin{:});
  case 'mscale', q=reduceMScale(p,varargin{:});
  case 'kdtree', [q,o2,o3]=reduceKD(p,varargin{:});
  otherwise, error('Unknown type for reduce!');
end;
%fprintf('%d points (%f effective)\n',getNpts(q),getNeff(q));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function q=reduceGrad(p,N,klMethod)
  if (nargin < 3) klMethod = 'LLN'; end;
  ks = getBW(ksize(p,'rot'),1);   % find ROT ksize for new kernel locations using
  dim = getDim(p);                % old ROT & adjusting for new # of kernels
  ks = ks * (N/getNpts(p))^(-1/(4+dim));
  q = resample(p,N);              % init to something at random
  adjustBW(q,ks);                 % set the BW to above value
  tol = 1e-4;
  alpha = .01; err2OLD = zeros(dim,N); err2 = [1];
  while (alpha * max(max(err2)) > 1e-5),  % and start doing grad. ascent
    [err1, err2] = klGrad(p,q,klMethod);
    adjustPoints(q,-alpha*err2);          % Use self-adjusting rate
    if (min(err2 .* err2OLD)>=0) alpha = alpha/.95;
    else alpha = alpha/1.4142; end;
    err2OLD = err2;
  end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function q=reduceMScale(p,k)
  pts = getPoints(p);          
  [nn,r] = knn(p,pts,k+1);
  [rsort,ind] = sort(r);
  keep = [];
  while (length(ind))
    keep = [keep,ind(1)];
    outside = find( sqrt(sum((repmat(pts(:,ind(1)),[1,length(ind)])-pts(:,ind)).^2,1)) > 2*rsort(1) );
    ind = ind(outside);
  end;
  q = kde(pts(:,keep),'rot');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function q=reduceRSDE(p,type,isetype)
  global kdeReduceType;
  global kdeISEType;
  if (nargin < 2) type = 'smo'; end;               % Default to seq. min. optimization
  if (nargin < 3) isetype = 0; end; kdeISEType = isetype; % and exact ISE
  switch (lower(type)),
    case 'qp', kdeReduceType = 1;
    case 'smo', kdeReduceType = 2;
    case 'mult', kdeReduceType = 3;
    otherwise, error('Unknown reduce RSDE solve method!');
  end;

  if (p.type ~= 0) 
    error('Sorry! This method only supports Gaussian kernels currently.'); 
    % Non-gaussian kernels : convolution operator below is harder. 
  end;

  [minm,maxm] = neighborMinMax(p);            % Search over bandwidths:
  ks =  golden(p,@quality,2*minm/(minm+maxm),1,2*maxm/(minm+maxm),1e-2);
  q = reduceKnownH(p,ks,kdeReduceType);

function res = quality(h,p)             % Evaluate quality using ISE estimate
  global kdeReduceType;                 %  (note, the minimum given by ISE
  global kdeISEType;                    %   is actually a pretty good  
  q = reduceKnownH(p,h,kdeReduceType);  %   estimate of the true min of KL)
  res = ise(p,q,kdeISEType);            %
                                        % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pnew = reduceKnownH(p,alpha,type)
  pts = getPoints(p); N = getNpts(p); d = getDim(p);
  q = kde(p); q.bandwidth = q.bandwidth * alpha; % For a given bandwidth "h"
  D=evaluate(q,p); Q = gramConvolved( q );       % find w : min w*Q*w' + 2*w*D'
  if (type == 1) newWts=quadprog(Q,D,-eye(N),zeros(1,N),ones(1,N),1);
  else newWts = reduceSolve(Q,D,type);           %   via Quadratic Optimization
  end;
  if (size(q.bandwidth,2)> 2*N) BW = getBW(q,find(newWts));
  else BW = getBW(q,1); 
  end;
  pnew = kde(pts(:,find(newWts)),BW,newWts(find(newWts)));

function [minm,maxm] = neighborMinMax(npd)    % Use this to determine the searching
  maxm = sqrt(sum( (2*npd.ranges(:,1)).^2) ); %  range for valid "h"
  minm = min(sqrt(sum( (2*npd.ranges(:,1:npd.N-1)).^2 ,1)),[],2);
  minm = max(minm,1e-6);

function G = gramConvolved(p)                 % Compute Q_ij = \int K(x,xi)K(x,xj)
  pts = getPoints(p); N = getNpts(p); d = getDim(p);
  G = zeros(N);
  for i=1:N
    dummy=pts(:,i:end)-repmat(pts(:,i),1,N-i+1);
    BW = getBW(p,i:N).^2 + repmat(getBW(p,i).^2,[1,N-i+1]);
    tmp = -0.5*sum(dummy.^2./BW + log(BW) ,1);
    G(i,i:N) = tmp; G(i:N,i) = tmp';
  end
  G = exp(G) ./ (2*pi)^(d/2);
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function q=reduceEM(p,k)
  pts = getPoints(p); N = size(pts,2); d = size(pts,1);
  plt = -1:.01:4; 
  % check to verify that BW is uniform... !!!
  if (size(p.bandwidth,2)>2*N)
    error('Reduce: EM: only works with uniform bandwidths...');
  else BW = getBW(p,1);
  end;

  % create random assortmend of "k" diagonal covar Gaussians
  %initInd = randperm(N); initInd=initInd(1:k);
  %for i = 1:k, GM{i} = kde(pts(:,initInd(i)),BW); end;
  for i = 1:k, GM{i} = kde(sample(p,1),BW); end;
  converged=0; mean=zeros(d,k); var=zeros(d,k); wts=zeros(k,N);
  while (~converged)
    converged = 1; meanOld = mean; varOld = var;
  %   find relative weights of all points for each mixture component
    for i=1:k, wts(i,:) = evaluate(GM{i},pts); end;
    wts = wts ./ repmat(sum(wts,1),[k,1]); % normalize
    for i=1:k,  %   compute conditional mean & variance & update
      mean(:,i) = pts*wts(i,:)' ./ sum(wts(i,:)); 
      ptsM = pts - repmat(mean(:,i),[1,N]);
      var(:,i) = ptsM.^2 * wts(i,:)' ./ sum(wts(i,:));
      var(:,i) = var(:,i) + BW.^2;     % adjust for smoothing factor...
      if (norm(mean(:,i)-meanOld(:,i)) > 1e-5) converged = 0; end;
      if (norm(var(:,i)-varOld(:,i)) > 1e-5) converged = 0; end;
      GM{i} = kde(mean(:,i),sqrt(var(:,i)) );
    end;
  end
  % combine & convolve (add variance / already added) of fine-scale BW
  %q = kde(mean,sqrt(var + repmat(BW.^2,[1,k])),sum(wts,2)');
  q = kde(mean,sqrt(var),sum(wts,2)');

