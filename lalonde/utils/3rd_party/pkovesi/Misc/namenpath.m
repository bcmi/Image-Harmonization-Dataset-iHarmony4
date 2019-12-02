% NAMENPATH   Returns filename and its path from a full filename
%
% Usage: [name, pth] = namenpath(fullfilename)
%
% Argument:  fullfilename - filename specifier which may include directory
%                           path specification
%
% Returns:  name - The filename without directory path specification
%            pth - The directory path
%                  such that fullfilename = [pth name]

% Copyright (c) 2010 Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% peter.kovesi at uwa edu au

% July 2010

function [name, pth] = namenpath(fullfilename)
    
    % Find the last instance of a forward or back slash in the full file name 
    ind = find(fullfilename == '/' | fullfilename =='\', 1, 'last');

    if isempty(ind)
        pth  = './';
        name = fullfilename;
    else
        pth  = fullfilename(1:ind);    
        name = fullfilename(ind+1:end);
    end
