%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function c=getClassFromLabeling(x)
%   Returns the class (as labeled) in the annotation.
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c = getClassFromLabeling(x)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~sscanf(x.image.generated, '%d')
    c = 'Real';
    return;
end

if isfield(x, 'class')
    nbLabelers = length(x.class);

    type = x.class(1).type;
    for i=2:nbLabelers
        if ~strcmp(type, 'o') && ~strcmp(type, x.class(i).type) && ~strcmp(x.class(i).type, 'o')
            type = 'c';
            break;
        else
            type = 'o';
        end
    end

    if strcmp(type, 'r')
        c = 'Realistic';
    elseif strcmp(type, 'u')
        c = 'Unrealistic';
    elseif strcmp(type, 'c')
        c = 'Unsuccessful';
    elseif strcmp(type, 'o')
        c = 'Unsuccessful';
    end
else
    c = 'Unlabeled';
end