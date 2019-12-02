function [q,e,c]=reduceKD(p,varargin)
% KD-tree based density reduction method of Ihler et al, 2004.
%
costType = 'kld'; maxCost = .01; 
costs = ones(1,2*getNpts(p));		% cost-matrix in terms of # components
for i=1:length(varargin)
  if (isa(varargin{i},'char')), costType = varargin{i}; end;
  if (isa(varargin{i},'double') && numel(varargin{i})==1), maxCost = varargin{i}; end;
  if (isa(varargin{i},'uint32') && numel(varargin{i})==1), maxCost = varargin{i}; end;
  if (isa(varargin{i},'double') && numel(varargin{i})>1), costs = varargin{i}; end;
end;

bw = getBW(p,1); out = kde(mean(p),3*sqrt(covar(p))); outW = .99; N = getNpts(p);
d=zeros(1,2*N);

%%%%%%%%% Specify "Cost" in terms of # of components %%%%%%%%%%%%%%%%%%%%
if (isa(maxCost,'uint32'))  
  ind = [1]; eC=zeros(1,2*N); eC(1) = err(p,1,bw,out,outW,costType,d);
  done = ind; minEC = eC(1); thisEC=minEC; 
  while (sum(costs(ind))<maxCost)    % compare p(below ind) to q(ind):
    [tmp,i] = max(eC); ind = setdiff(ind,i); eC(i) = 0;
    ii=double(p.leftch(i))+1;  d(ii) = d(i)+1;
      eC(ii) = err(p,ii,bw,out,outW,costType,d); ind=[ind,ii];
    ii=double(p.rightch(i))+1; d(ii) = d(i)+1;
      eC(ii) = err(p,ii,bw,out,outW,costType,d); ind=[ind,ii];
    if (strcmp(costType,'maxlog')) thisEC = max(eC); else thisEC = sum(eC); end;
%%%%%
%    q = kde(p.means(:,ind),sqrt(p.bandwidth(:,ind)),p.weights(ind));
%    if     (strcmp(costType,'maxlog')) thisEC=max(abs( log(evaluate(p,p))-log(evaluate(q,p)) ));
%    elseif (strcmp(costType,'ise'))    thisEC = 2.^depth(ii) .* p.weights(ii).^2 .* ise(p,q,1e-3);
%    elseif (strcmp(costType,'kld'))    thisEC = p.weights(ii) .* abs(kld(p,q));
%    elseif (strcmp(costType,'L1'))     thisEC = p.weights(ii) .* abs(L1(p,q));
%    end;
%%%%%
    if (thisEC < minEC && sum(costs(ind)) < maxCost) done = ind; minEC=thisEC; end;
  end;
else %%%%%%%%% Or,"Cost" in terms of max error %%%%%%%%%%%%%%%%%%%%
  ind = [1]; eC=zeros(1,2*N); eC(1)=err(p,1,bw,out,outW,costType,d);
  done = ind; minEC=eC(1); thisEC=minEC; 
  while (thisEC>maxCost)    % compare p(below ind) to q(ind):
    [tmp,i] = max(eC); ind = setdiff(ind,i); eC(i) = 0;
    ii=double(p.leftch(i))+1;  d(ii)=d(i)+1;
      eC(ii) = err(p,ii,bw,out,outW,costType,d); ind=[ind,ii];
    ii=double(p.rightch(i))+1; d(ii)=d(i)+1;
      eC(ii) = err(p,ii,bw,out,outW,costType,d); ind=[ind,ii];
    if (strcmp(costType,'maxlog')) thisEC = max(eC); else thisEC = sum(eC); end;
    if (thisEC < minEC) done = ind; minEC = thisEC; end;
  end;
end;
means = p.means(:,done);
wts   = p.weights(:,done);
bws   = p.bandwidth(:,done);
c = sum(costs(done));  e = minEC;
q = kde(means,sqrt(bws),wts); %q = joinTrees(q,out,outW);

function eC = err(p,ii,bw,out,outW,cT,depth)
  pp = kde( p.means(:,1+[double(p.lower(ii)):double(p.upper(ii))]), bw);
  qq = kde( p.means(:,ii), sqrt(p.bandwidth(:,ii)) );
  if (strcmp(cT,'maxlog'))
    pp = joinTrees(pp,out,outW); qq = joinTrees(qq,out,outW);
  end;
  if     (strcmp(cT,'maxlog')) eC=max(abs( log(evaluate(pp,pp))-log(evaluate(qq,pp)) ));
  elseif (strcmp(cT,'ise'))    eC = 2.^depth(ii) .* p.weights(ii).^2 .* ise(pp,qq,1e-3);
  elseif (strcmp(cT,'kld'))    eC = p.weights(ii) .* abs(kld(pp,qq));
  elseif (strcmp(cT,'L1'))     eC = p.weights(ii) .* abs(L1(pp,qq));
  else   error('Unknown cost type...');
  end;
 
function e = L1(p,q) % simple plug-in estimate of L1-error
  x = getPoints(p); w = getWeights(p);
  e = w * abs(1-evaluate(q,x)./evaluate(p,x))';
  
