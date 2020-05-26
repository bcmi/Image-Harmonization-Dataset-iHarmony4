% BASENAME  Trims off the .ending of a filename
%
% Usage:  bname = basename(name)
%
% Argument:   name - Name of a file with a .ending
% Returns:   bname - Name with the suffix trimmed

% Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% peter.kovesi at uwa edu au
%
% August 2010

function bname = basename(name)
    
    % Find last instance of a '.' in the file name
    ind = find(name == '.', 1, 'last');
    
    if isempty(ind)
        bname = name;
    else
        bname = name(1:ind(end)-1);
    end
