function q=reduceKD(p,maxCost,costType)
if (nargin < 3) costType = 1; end; % "max" cost
if (nargin < 2) maxCost = round(getNpts(p)/10); end;

bw = getBW(p,1); out = kde(mean(p),3*covar(p)); outW = .999; N = getNpts(p);

ind = [1]; done = []; eC=zeros(1,2*N); eC(1) = cost(p,1,bw,out,outW,costType);
  done = ind; minEC = eC(1);
while (length(ind)<maxCost)    % compare p(below ind) to q(ind):
  [tmp,i] = max(eC); ind = setdiff(ind,i); eC(i) = 0; 
  ii=double(p.leftch(i))+1;  eC(ii) = cost(p,ii,bw,out,outW,costType); ind=[ind,ii];
  if (costType~=1) eC(ii) = p.weights(ii) * eC(ii); end;
  ii=double(p.rightch(i))+1; eC(ii) = cost(p,ii,bw,out,outW,costType); ind=[ind,ii];
  if (costType~=1) eC(ii) = p.weights(ii) * eC(ii); end;
  if (costType==1) thisEC = max(eC); else thisEC = sum(eC); end;
  if (thisEC < minEC) done = ind; end;
end;
means = p.means(:,done);
wts   = p.weights(:,done);
bws   = p.bandwidth(:,done);
q = kde(means,sqrt(bws),wts); %q = joinTrees(q,out,outW);

function eC = cost(p,ii,bw,out,outW,costType)
  tmpP = kde( p.means(:,1+[double(p.lower(ii)):double(p.upper(ii))]), bw);
  tmpQ = kde( p.means(:,ii), sqrt(p.bandwidth(:,ii)) );
  tmpP = joinTrees(tmpP,out,outW); tmpQ = joinTrees(tmpQ,out,outW);
  eC = errCost(tmpP,tmpQ,p,costType);

function xC=xmitCost(x,w,H,R)
  xC = (H+R)*length(find(w>0)) - log(factorial(length(find(w>0))));
  
function eC=errCost(p,q,p0,costType)
  evalLoc = discretization( [-1:.02:1],[-1:.02:1]);
  if (costType == 1)
    eC = logerr(p,q); %
%    eC = max(abs(log(evaluate(p,evalLoc)./evaluate(q,evalLoc))));
  elseif (costType == -1)
    eC = kld(p,q);  eC = abs(eC);
%    evalLoc = -1:.01:2;
%    pnorm = evaluate(p,evalLoc); pnorm = pnorm ./ sum(pnorm);
%    qnorm = evaluate(q,evalLoc); qnorm = qnorm ./ sum(qnorm);
%    eC = sum(pnorm.*log(pnorm./qnorm));
  else
    pnorm = evaluate(p0,evalLoc); pnorm = pnorm ./ sum(pnorm);
    eC = sum(pnorm.*abs(log(evaluate(p,evalLoc)./evaluate(q,evalLoc))));
  end;
