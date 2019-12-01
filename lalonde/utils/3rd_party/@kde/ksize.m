function npd = ksize(npd,type,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% KSIZE    Find optimal kernel size for kernel density estimates 
%
%   Q=KSIZE(P) returns a KDE with the same points and type as "P", but whose 
%   bandwidth has been determined by one of a number of data-based selection methods. 
%   Optional arguments:
%   KSIZE(P,'type' [,options]) where 'type' is one of:
%     'unif' or 'lcv'  -- (default) spherical, uniform likelihd cross-valid. search (1d)
%     'local' [,P0]    -- lcv optimization, preprocessed to be proportional to P0 [1xNpts]
%                          (Default: P0 = sqrt(N)-nearest nbr distance of each point)
%     'rot'            -- (fast) "Rule of Thumb" asymptotic estimator (Silverman)
%     'msp'            -- (fast) "Maximal Smoothing Principle" (close to ROT) (Terrel)
%     'hall' or 'hsjm' -- plug-in estimator of Hall,Sheather,Jones,Marron (91)
%     'maxmin'         -- ad-hoc method: sqrt of max of nearest-nbr distances
%
%   Ending the string with 'p' (e.g. 'lcvp') causes the data to be normalized by its
%   variance before finding the bandwidth (and transformed back afterwards)
%   This is useful when the scales of the dimensions are very different.
%
%   See also: kde, adjustBW 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

  Nd = npd.D; Np = npd.N;
  if (Np==1) npd = kde(getPoints(npd),0,getWeights(npd),getType(npd)); end;
  if (nargin<2) type='lcv'; end;

  if (isa(type,'double')), ks = type; 		  % Passed a value, not a type?
    if (length(ks)==1) ks = ks + zeros(Nd,1); end;
    npd = kde(getPoints(npd),type,getWeights(npd),getType(npd));
    return;
  end;

  type = lower(type);
  if (type(end)=='p')
    stddv = covar(npd,0);                         % pre-equalize variances for
    npd = rescale(npd, 1./stddv);                 %   any 1-d calculations
  end;
  
  switch lower(type)        %%%% KERNEL SIZE SELECTION METHODS  %%%%%
      
  %%%% LEAST-SQUARES CROSS-VALIDATION %%%%   
  case {'lscv','lscvp'},                    % least-squares cross-validation
    ks = ksizeLSCV(npd);

  %%%% LIKELIHOOD CROSS-VALIDATION BASED %%%%   
  case {'lcv','unif','lcvp','unifp'},       % (uniform) likelihood cross-validation
    [minm,maxm] = neighborMinMax(npd);
    npd = kde(getPoints(npd),(minm+maxm)/2,getWeights(npd),getType(npd));
    ks =  golden(npd,@nLOO_LL,2*minm/(minm+maxm),1,2*maxm/(minm+maxm),1e-2);
    ks = ks * (minm+maxm)/2;
    
  case {'local','localp'},                   % local likelihood cross-val
    if (nargin < 3) 
      [prop,minm,maxm] = neighborDistance(npd,sqrt(getNpts(npd)));
    else prop = varargin{1}; [minm,maxm] = neighborMinMax(npd);
    end;
    prop = prop / mean(prop);
    npd = kde(getPoints(npd),(minm+maxm)/2 * prop,getWeights(npd),getType(npd));
    ks =  golden(npd,@nLOO_LL,2*minm/(minm+maxm),1,2*maxm/(minm+maxm),1e-2);
    ks = ks * (minm+maxm)/2 * prop;
    
  %%%% STANDARD-DEVIATION BASED %%%%   
  case {'rot'},                     % "Rule of Thumb" (stddev-based)
    ks = ksizeROT(npd);
  case {'msp'},                     % "Maximal Smoothing Principle"
    ks = ksizeMSP(npd);             %  same as ROT but different constants

  %%%% "PLUG-IN" BASED ON APPROX MISE ASYMPTOTICS %%%%
  case {'hall','hsjm'},
    ks = ksizeHall(npd);    

  case {'maxmin'},                  % Maximum of the minimum neighbor distance
    [nn,prop] = knn(npd,getPoints(npd),1+1);
    ks = sqrt(max(prop));
    
  end;

  if (type(end)=='p')
    ks = repmat(ks,[Nd,1]./[size(ks,1),1]);
    ks = ks .* repmat(stddv,size(ks)./size(stddv)); % fix up prev. equalization
    npd = rescale(npd, stddv);                      %   and changed npd points      
  end;

  npd = kde(getPoints(npd),ks,getWeights(npd),getType(npd));
  
  
function H = nLOO_LL(alpha,npd)
  if (nargin < 2) error('ksize: LOO_LL: Error!  Too few arguments'); end;
  if (npd.type == 0) alpha = alpha.^2; end;
  npd.bandwidth = npd.bandwidth * alpha;
  H = entropy(npd,'lvout');
  npd.bandwidth = npd.bandwidth / alpha;

  
function [prop,minm,maxm] = neighborDistance(npd,Nnear)
%    if (exist('knn'))
      [nn,prop] = knn(npd,getPoints(npd),round(Nnear)+1);
      [minm, maxm] = neighborMinMax(npd);
%    else
%      points = getPoints(npd);
%      [N1,N2] = size(points);
%      X1  = repmat(points,[1,1,N2]);
%      X2  = permute(repmat(points,[1,1,N2]),[1,3,2]);
%      dist= permute(sum( (X1-X2).^2,1),[2,3,1]);
%      dist= sqrt(sort(dist,1));
%      prop= dist(round(Nnear),:);
%      [minm,maxm] = neighborMinMax(npd);
%    end;

function [minm,maxm] = neighborMinMax(npd)
    maxm = sqrt(sum( (2*npd.ranges(:,1)).^2) );
    minm = min(sqrt(sum( (2*npd.ranges(:,1:npd.N-1)).^2 ,1)),[],2);
    minm = max(minm,1e-6);
