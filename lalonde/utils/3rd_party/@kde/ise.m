function v = ise(p,q,type)
%
% ise(p,q [,'type'])  -- estimate the integrated squared error between 
%                        two densities p,q
%   type:
%    [double] -- use "epsilon-exact" product with this value for epsilon
%    'p','q'  -- use the samples at p (or at q)
%    'pq'     -- use both samples at p & q
%
if (nargin < 3) type = 0; end;
if (isa(type,'double'))  v = iseEpsilon(p,q,type);
else
  switch type
    % Three different monte-carlo estimates (different proposals)
    case {'p'}, x = getPoints(p); quo = evaluate(p,x);
                v = mean( (evaluate(p,x) - evaluate(q,x)).^2 ./ quo);
    case {'q'}, x = getPoints(q); quo = evaluate(q,x);
                v = mean( (evaluate(p,x) - evaluate(q,x)).^2 ./ quo);
    case {'pq'},x = [getPoints(p),getPoints(q)]; quo = .5*(evaluate(p,x)+evaluate(q,x));
                v = mean( (evaluate(p,x) - evaluate(q,x)).^2 ./ quo);
    % and one (possible) estimate from Mark Girolami
    case {'abs'},   eval1 = evaluate(p,p); eval2 = evaluate(q,p);
                    if (min(eval2) == 0) v = inf;
                    else v = getWeights(p) * (eval1 .* abs(log(eval1./eval2)))';
                    end;

  end;
end;
