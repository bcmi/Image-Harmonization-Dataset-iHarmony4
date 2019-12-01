% PATHLIST  Produces a cell array of directories along a directory path
%
% Usage:  plist = pathlist(fullpath)
%
% Example:  If fullpath = '/Users/pk/Matlab/Spatial'
%           plist =
%   '/'  '/Users/'  '/Users/pk/'  '/Users/pk/Matlab/'  '/Users/pk/Matlab/Spatial'
%
% plist{end} is always fullpath
% plist{end-1} is the parent directory
% etc
%
% Not sure if this works appropriately under Windows

% Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% peter.kovesi at uwa edu au
%
% September 2010

function plist = pathlist(fullpath)
    
     % Find locations of a forward or back slash in the full file name 
    ind = find(fullpath == '/' | fullpath =='\');
    
    % If there were no / or \ in the full path just return fullpath
    if isempty(ind)
        plist{1} = fullpath;
        
    else % Step along the path and extract each incremental part

        for n = 1:length(ind)
            plist{n} = fullpath(1:ind(n));
        end
    
        % If there is no / or \ at the end of the full path make fullpath the
        % final entry in the list
        if ind(end) ~= length(fullpath)
            plist{n+1} = fullpath;
        end
    end
    
