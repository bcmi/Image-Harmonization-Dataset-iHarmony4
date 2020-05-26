function [membership,means,rms] = kmeansML(k,data,varargin)
% [membership,means,rms] = kmeansML(k,data,...)
%
% Multi-level kmeans.  
% Tries very hard to always return k clusters.
%
% INPUT
%	k		Number of clusters
% 	data		dxn matrix of data points
%	'maxiter'	Max number of iterations. [30]
%	'dtol'		Min change in center locations. [0]
%	'etol'		Min percent change in RMS error. [0]
%	'ml'		Multi-level? [true]
%	'verbose'	Verbose level. [0]
%			    0 = none
%			    1 = textual
%			    2 = visual
%
% OUTPUT
% 	membership	1xn cluster membership vector
% 	means		dxk matrix of cluster centroids
%	rms		RMS error of model
%
% October 2002
% David R. Martin <dmartin@eecs.berkeley.edu>

% process options
maxIter = 30;
dtol = 0;
etol = 0;
ml = true;
verbose = 0;
for i = 1:2:numel(varargin),
  opt = varargin{i};
  if ~ischar(opt), error('option names not a string'); end
  if i==numel(varargin), error(sprintf('option ''%s'' has no value',opt)); end
  val = varargin{i+1};
  switch opt,
   case 'maxiter', maxIter = max(1,val);
   case 'dtol', dtol = max(0,val);
   case 'etol', etol = max(0,val);
   case 'ml', ml = val;
   case 'verbose', verbose = val;
   otherwise, error(sprintf('invalid option ''%s''',opt));
  end
end

[membership,means,rms] = ...
    kmeansInternal(k,data,maxIter,dtol,etol,ml,verbose,1);

function [membership,means,rms] = kmeansInternal(...
    k,data,maxIter,dtol,etol,ml,verbose,retry)

[d,n] = size(data);
perm = randperm(n);

% compute initial means
rate = 3;
minN = 50;
coarseN = round(n/rate);
if ~ml | coarseN < k | coarseN < minN,
  % pick random points as means
  means = data(:,perm(1:k));
else
  % recurse on random subsample to get means
  coarseData = data(:,perm(1:coarseN));
  [coarseMem,means] = ...
      kmeansInternal(k,coarseData,maxIter,dtol,etol,ml,verbose,0);
end

% Iterate.
iter = 0;
rms = inf;
if verbose>0, fwrite(2,sprintf('kmeansML: n=%d d=%d k=%d [',n,d,k)); end
while iter < maxIter,
  if verbose>0, fwrite(2,'.'); end
  iter = iter + 1;
  % Compute cluster membership and RMS error.
  rmsPrev = rms;
  [membership,rms] = computeMembership(data,means);
  % Compute new means and cluster counts.
  prevMeans = means;
  [means,counts] = computeMeans(k,data,membership);
  % The error should always decrease.
  if rms > rmsPrev, error('bug: rms > rmsPrev'); end
  % Check for convergence.
  rmsPctChange = 2 * (rmsPrev - rms) / (rmsPrev + rms + eps);
  maxMoved = sqrt(max(sum((prevMeans-means).^2)));
  if rmsPctChange <= etol & maxMoved <= dtol, break; end
  % Visualize.
  if verbose>1, kmeansVis(data,membership,means); end
end
[membership,rms] = computeMembership(data,means);
if verbose>0, fwrite(2,sprintf('] rms=%.3g\n',rms)); end

% If there's an empty cluster, then re-run kmeans.
% Retry a fixed number of times.
maxRetries = 3;
if find(counts==0), 
  if retry < maxRetries,
    disp('Warning: Re-runing kmeans due to empty cluster.');
    [membership,means] = kmeansInternal( ...
        k,data,maxIter,dtol,etol,ml,verbose,retry+1);
  else
    disp('Warning: There is an empty cluster.');
  end
end

function [membership,rms] = computeMembership(data,means)
z = distSqr(data,means);
[d2,membership] = min(z,[],2);
rms = sqrt(mean(d2));

function [means,counts] = computeMeans(k,data,membership)
[d,n] = size(data);
means = zeros(d,k);
counts = zeros(1,k);
for i = 1:k,
  ind = find(membership==i);
  counts(i) = length(ind);
  means(:,i) = sum(data(:,ind),2) / max(1,counts(i));
end
  
%  for i = 1:n,
%    j = membership(i);
%    means(:,j) = means(:,j) + data(:,i);
%    counts(j) = counts(j) + 1;
%  end
%  for j = 1:k,
%    means(:,j) = means(:,j) / max(1,counts(j));
%  end

