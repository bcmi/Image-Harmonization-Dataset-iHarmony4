function tf=isnear(a,b,tol)
%ISNEAR True Where Nearly Equal.
% ISNEAR(A,B) returns a logical array the same size as A and B that is True
% where A and B are almost equal to each other and False where they are not.
% A and B must be the same size or one can be a scalar.
% ISNEAR(A,B,TOL) uses the tolerance TOL to determine nearness. In this
% case, TOL can be a scalar or an array the same size as A and B.
%
% When TOL is not provided, TOL = SQRT(eps).
%
% Use this function instead of A==B when A and B contain noninteger values.

% D.C. Hanselman, University of Maine, Orono, ME 04469
% Mastering MATLAB 7
% 2005-03-09

%--------------------------------------------------------------------------
if nargin==2
   tol=sqrt(eps);
end
if ~isnumeric(a) || isempty(a) || ~isnumeric(b) || isempty(b) ||...
   ~isnumeric(tol) || isempty(tol)
   error('Inputs Must be Numeric.')
end
if any(size(a)~=size(b)) && numel(a)>1 && numel(b)>1
   error('A and B Must be the Same Size or Either can be a Scalar.')
end
tf=abs((a-b))<=abs(tol);