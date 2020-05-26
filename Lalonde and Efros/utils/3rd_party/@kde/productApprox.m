function [dens,ind] = productApprox(npd0, npds , anFns,anParams , type, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate an approximate density for the product of the input densities using
%   MCMC approach
%
% productApprox(npd, {npdensities...}, {analyticFunctions...}, {analyticParams...},
%                    type, [options] )
%
%  {npdensities...} =  cell array of kernel density estimates in product
%  type = product method, one of: 'exact', 'epsilon', 'gibbs1', 'gibbs2', ...
%  OPTIONS: 
%   'exact': no add'l arguments
%   'epsilon':  [,tol]         -- use tolerance tol when sampling approximately
%   'gibbs1':   [,Niter]       -- Niter iterations of sequential gibbs sampling
%   'gibbs2':   [,Niter]       -- "" of parallel gibbs sampling
%   'gibbsMS1' (or 2) [,Niter] -- Niter iters *per scale* in multiscale versions
%   Importance Samplers:    
%     args: alpha = sample alpha*N times, weight, then resample
%           type = 'repeat' (default), 'unique' -- unique, weighted samples (< N)
%     'import' [,alpha,type]  -- "mixture" importance sampling 
%     'importG' [,alpha,type] -- "gaussian" importance sampling
%     'importPair' [...]      -- use sum of epsilon products of all pairs as proposal
%     'importNoAn' [...]      -- "mixture" importance sampling, but resampling BEFORE
%                                analytic function evaluation (for costly anFns)
%
%  {analyticFns...} =  cell array of analytic functions in product
%  {analyticPar...} =  cell array of parameters for above functions
%      each should take [Nd x Np] array and evaluate it at each [Nd x 1] location
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% See  Ihler,Sudderth,Freeman,&Willsky, "Efficient multiscale sampling from products
%         of Gaussian mixtures", in Proc. Neural Information Processing Systems 2003
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

  for i=1:length(npds)
    if (npds{i}.type ~= 0) error('Sorry! Product only works for Gaussian densities.'); end;
  end;

  % if there's only one density, don't bother with the complex stuff:
  if (length(npds) == 1) 
      dens = resample(npds{1},getNpts(npd0),'rot'); ind=[];
      p = getPoints(dens); w = getWeights(dens);
      for i=1:length(anFns),
        w = w .* feval(anFns{i},p,anParams{i}{:});
        w = w / sum(w);
      end;
      dens = kde(p, 'rot', w);

  % Otherwise, lots of ways to take the product:
  else
  w    = ones(1,getNpts(npd0));
  switch(lower(type))
      case 'exact',   [p,ind] = prodSampleExact(npds,getNpts(npd0));
      case 'epsilon', [p,ind] = prodSampleEpsilon(npds,getNpts(npd0),varargin{:});
      case 'gibbs1',  [p,ind] = prodSampleGibbs1(npds,getNpts(npd0),varargin{:});
      case 'gibbs2',  [p,ind] = prodSampleGibbs2(npds,getNpts(npd0),varargin{:});
      case 'gibbsms1',[p,ind] = prodSampleGibbsMS1(npds,getNpts(npd0),varargin{:});
      case 'gibbsms2',[p,ind] = prodSampleGibbsMS2(npds,getNpts(npd0),varargin{:});
      case 'import',  [p,w] = prodSampleImportMix(npds,getNpts(npd0),anFns,anParams,varargin{:});
      case 'importg', [p,w] = prodSampleImportGauss(npds,getNpts(npd0),anFns,anParams,varargin{:});
      case 'importpair',[p,w]=prodSampleImportPair(npds,getNpts(npd0),anFns,anParams,varargin{:});
      case 'importnoan',[p,w] = prodSampleImportMix(npds,getNpts(npd0),{},{},varargin{:});
      otherwise, error('Unknown product type %s',type);
  end;

  switch(lower(type))
    case {'import','importg','importpair'}
      if ( 1/sum(w.^2)<.02*getNpts(npd0) || max(w)==0 )
        warning('KDE:importFail','Importance sampling failed.  Generating samples with GibbsMS...');  
        [p,ind] = prodSampleGibbsMS1(npds,getNpts(npd0),5); % quick & dirty fix
        w = ones(1,getNpts(npd0));
        for i=1:length(anFns), w=w.*feval(anFns{i},p,anParams{i}{:});w=w/sum(w);end;
      end;
    otherwise
      for i=1:length(anFns),
        w = w .* feval(anFns{i},p,anParams{i}{:});
        w = w / sum(w);
      end;
  end;
  dens = kde(p, 'rot', w);
  end;
