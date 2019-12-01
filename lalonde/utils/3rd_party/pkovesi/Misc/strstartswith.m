% STRSTARTSWITH - tests if a string starts with a specified substring
%
% Usage: b = strstartswith(str, substr)
%
%  Arguments:
%        str   - string to be tested
%     substr   - starting string that we are hoping to find
%
%   Returns: true/false. Note that case of strings is ignored
% 
% See also: STRENDSWITH

% Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% http://www.csse.uwa.edu.au/~pk/research/matlabfns/
% June  2010

function b = strstartswith(str, substr)
    
    l = length(substr);
    
    % True if ssubstring not too long and all appropriate characters match
    % (ignoring case)
    b =  l <= length(str) && strcmpi(str(1:l), substr);
    
