function BW=findBWCrit(p,Nmodes)
% BW = findBWCrit(p,Nmodes)
% find Silverman's "Critical Bandwidth" -- min BW s.t. the number of modes
%     is less than or equal to Nmodes (can be a vector)
%

if (p.type ~= 0) warning('Poorly defined operation for non-Gaussian KDEs'); end;

q = kde(p);  % Copy p & get max requested # of nodes
Nmodes = sort(Nmodes);
BW = zeros(getDim(q),length(Nmodes));

% Find crit BW of nMax
minm = min(sqrt(sum( (2*q.ranges(:,1:q.N-1)).^2 ,1)),[],2);
minm = max(minm,1e-6);
adjustBW(q,minm*ones(getDim(q),1));    % gotta be bigger than this
m = modes(q);

for i=length(Nmodes):-1:1
  Nm = Nmodes(i);
  stepsize = 2;
  while (stepsize > 1.001)
    adjustBW(q, getBW(q,1) * stepsize);
    m2 = modes(q,m);
    if (size(m2,2) > Nm), m = m2; % if still OK, keep going, else back off & slow
    else adjustBW(q, getBW(q,1)/stepsize); stepsize = .9*stepsize; end;
  end;
  BW(:,i) = getBW(q,1);
end;
