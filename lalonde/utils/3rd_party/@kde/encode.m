function C = encode(p,R)
%
% Compute vector of transmit costs for each stage of the KD-tree
%

N = getNpts(p);  bw = getBW(p,1);
if (size(p.bandwidth,2) > 2*N)
  error('Encoding of variable bandwidths not yet supported...');
end;
if (any( abs(getWeights(p) - 1/N) > 2*eps )) 
  error('Encoding of variable weights not yet supported...'); 
end;
C = zeros(1,2*N); C(1) = 2*getDim(p)*R;		% Root node...

for i=1:N-1,            % calc costs of splitting each node; 1/2 cost to each side
 if (~isLeaf(i,N))
  mu0 = p.means(:,i);				% get means of parent, children
  mu1 = p.means(:, double(p.leftch(i))+1);
  mu2 = p.means(:, double(p.rightch(i))+1);
  sig0= sqrt( p.bandwidth(:,i) );		% and bw's of parent, children
  sig1= sqrt( p.bandwidth(:,double(p.leftch(i))+1) );
  sig2= sqrt( p.bandwidth(:,double(p.rightch(i))+1) );
  sig0UB = sqrt(max( sig0.^2 - bw.^2, 2^-R));	% don't round down too far...

  [tmp,splitDim] = max( sig0UB );		% which dimension are we splitting on...
  %[tmp,splitDim2] = max( abs(mu0-mu1) + abs(mu0-mu2) );
  %if (splitDim ~= splitDim2) warning('Disagreement?'); end;

  % COMPUTE COST OF SENDING MEANS
  muMax = max(mu1,mu2); sigDiff = sig0.^2 - (mu1.^2 + mu2.^2 - mu0.^2);
  for j=splitDim,
    costMu = gauss( muMax(j), mu0(j), sig0UB(j).^2 ,1,R );
  end;
  for j = [1:splitDim-1,splitDim+1:getDim(p)];
    costMu = costMu + gauss2( mu1(j), mu0(j), 1*sig0UB(j).^2 ,1,R );
  end;
  
  % COMPUTE COST OF SENDING VARIANCES
  if (isLeaf(p.leftch(i),N) && isLeaf(p.rightch(i),N)), costSig = 0; costMu = 0;
  elseif (isLeaf(p.leftch(i),N) || isLeaf(p.rightch(i),N)), costSig = 0;
  else
    for j=splitDim,
      costSig = gauss2( sig1(j).^2 , sig0(j).^2/2, sig0(j).^2/4, 1, R);
    end; 
    for j = [1:splitDim-1,splitDim+1:getDim(p)]
      costSig = costSig + gauss2( sig1(j).^2 , sig0(j).^2, sig0(j).^2/2, 1, R);
    end;
  end;

  %[costMu,costSig]
  C(double(p.leftch(i))+1) = .5 * (C(i) + costMu + costSig);
  C(double(p.rightch(i))+1) = .5 * (C(i) + costMu + costSig);
 end;
end;

function v = gauss(x,mu,sig2,sigOut2,R)		% SIMPLE 1-SIDED GAUSSIAN
  v = R-log2(  2*1/sqrt(2*pi*sig2) .* exp(-(x-mu).^2 ./(2*sig2)) );

%function v = gauss(x,mu,sig2,sigOut2,R)	% 1-SIDED W/ OUTLIER PROCESS
%  v = R-log2(  2*1/sqrt(2*pi*sig2) .* exp(-(x-mu).^2 ./(2*sig2)) ); + ...
%               1/sqrt(2*pi*sig2) .* exp(-(x-mu).^2 ./(2*sigOut2)) );

function v = gauss2(x,mu,sig2,sigOut2,R)	% SIMPLE 2-SIDED GAUSSIAN
  v = R-log2(  1/sqrt(2*pi*sig2) .* exp(-(x-mu).^2 ./(2*sig2)) );

%function v = gauss2(x,mu,sig2,sigOut2,R)	% 2-SIDED W/ OUTLIER PROCESS
%  v = R-log2(  1/sqrt(2*pi*sig2) .* exp(-(x-mu).^2 ./(2*sig2))  + ...
%               1/sqrt(2*pi*sig2) .* exp(-(x-mu).^2 ./(2*sigOut2)) );

function b = isLeaf(ind,N)
  ind = double(ind);
  if (ind <= 0 || ind > 2*N) b = 0;
  elseif (ind <= N-1) b = 0;
  else b = 1;
  end;

