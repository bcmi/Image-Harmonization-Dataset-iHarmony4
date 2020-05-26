% STRENDSWITH - tests if a string ends with a specified substring
%
% Usage: b = strendswith(str, substr)
%
%  Arguments:
%        str   - string to be tested
%     substr   - ending of string that we are hoping to find.
%                substr may be a cell array of string endings, in this case
%                the function returns true if any of the endings match.
%
%   Returns: true/false. Note that case of strings is ignored
% 
% See also: STRSTARTSWITH

% Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% http://www.csse.uwa.edu.au/~pk/research/matlabfns/
% June  2010
% April 2011  Modified to allow substr to be a cell array

function b = strendswith(str, substr)

    if ~iscell(substr)
        tmp = substr;
        clear substr;
        substr{1} = tmp;
    end
    
    b = 0;
    for n = 1:length(substr)
        % Compute index of character in str that should match with the the first
        % character of str
        s = length(str) - length(substr{n}) + 1;
        
        % True if s > 0 and all appropriate characters match (ignoring case)
        b =  b || (s > 0 && strcmpi(str(s:end), substr{n}));
    end
