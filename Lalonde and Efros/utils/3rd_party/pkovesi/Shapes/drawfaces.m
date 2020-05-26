% DRAWFACES  Draws triangular faces defined by vertices and face vertex lists
%
% Usage: drawfaces(xyz, F, col)
%
% Arguments:
%              xyz - A nx3 matrix defining the vertex list, each row is the
%                    x,y,z coordinates of a vertex.
%                F - A mx3 matrix defining the face list.  Each row of F
%                    specifies the indices of the 3 vertices that make up the
%                    face. 
%              col - Optional colour specifier of the faces. This can be 'r',
%                    'g', 'b' 'w', k' etc or a RGB 3-vector.  
%                    Defaults to [1 1 1] (white).  If col is specified as the 
%                    string 'rand' each face is given a random colour.
%                    if col has n rows it is assumed that col specifies the
%                    colour to be used for each vertex, see documentation for
%                    PATCH.
%
% See also:  GPLOT3D, ICOSAHEDRON, GEODOME

% Copyright (c) 2009 Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% peter.kovesi at uwa edu au
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

% May 2009

function drawfaces(xyz, F, col)
    
    if ~exist('col', 'var')
        col = [1 1 1];
    end
    
    nPatch = size(F,1);
    nVert = size(xyz,1);

    if size(col,1) == nVert
        for p = 1:nPatch
            coords = xyz(F(p,:),:);
            h = patch(coords(:,1), coords(:,2), coords(:,3), col(F(p,:),:));
%            set(h,'EdgeColor','none');
        end        
    elseif strcmpi(col,'rand')
        for p = 1:nPatch
            coords = xyz(F(p,:),:);
            patch(coords(:,1), coords(:,2), coords(:,3),rand(1,3))
        end
    else
        for p = 1:nPatch
            coords = xyz(F(p,:),:);
            patch(coords(:,1), coords(:,2), coords(:,3), col)
        end
    end
    