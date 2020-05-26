%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function r = myfprintf(doDisplay, str, varargin)
%  Simple interface to fprintf which has an additional variable indicating
%  whether we should actually display the message or not.
% 
% Input parameters:
%
% Output parameters:
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret = myfprintf(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2008 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ischar(varargin{1})
    doDisplay = 1;
    str = varargin{1};
    args = varargin(2:end);
else
    doDisplay = varargin{1};
    str = varargin{2};
    args = varargin(3:end);
end

r = 0;
if doDisplay
    r = fprintf(str, args{:});
end

if nargout
    ret = r;
end
