function e = runFunctionTryCatch(fnHandle, varargin)
% Wraps a function in a try/catch statement. 
%
%   e = runFunctionTryCatch(fnHandle, ...)
%
% If the function works, e contains its output. Otherwise it contains the
% error. 
%
% See also:
%   runFunctionOnDatabase
% 
% ----------
% Jean-Francois Lalonde

try
    e = fnHandle(varargin{:});
catch e
    fprintf('Caught error: %s\n', e.message);
end
