% ICOSAHEDRON   Generates vertices and graph of icosahedron
%
% Usage: [xyz, A, F] = icosahedron(radius)
%
% Argument: radius - Optional radius of icosahedron. Defaults to 1.
% Returns:     xyz - 12x3 matrix of vertex coordinates.
%                A - Adjacency matrix defining connectivity of vertices.
%                F - 20x3 matrix specifying the 3 nodes that define each face.
%
% See also: GEODOME, GPLOT3D, DRAWFACES

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

function [xyz, A, F] = icosahedron(radius)
    
    if ~exist('radius','var')
        radius = 1;
    end
    
    % Compute the 12 vertices
    phi = (1+sqrt(5))/2;  % Golden ratio
    xyz = [0   1  phi 
           0  -1  phi 
           0   1 -phi 
           0  -1 -phi 
           1  phi  0  
          -1  phi  0  
           1 -phi  0  
          -1 -phi  0  
           phi 0   1  
          -phi 0   1  
           phi 0  -1  
          -phi 0  -1];

    % Scale to required radius
    xyz = xyz*radius/(sqrt(1+phi^2));
       
    % Define the adjacency matrix
    %    1 2 3 4 5 6 7 8 9 10 11 12
    A = [0 1 0 0 1 1 0 0 1 1  0  0  
         1 0 0 0 0 0 1 1 1 1  0  0  
         0 0 0 1 1 1 0 0 0 0  1  1  
         0 0 1 0 0 0 1 1 0 0  1  1  
         1 0 1 0 0 1 0 0 1 0  1  0  
         1 0 1 0 1 0 0 0 0 1  0  1  
         0 1 0 1 0 0 0 1 1 0  1  0  
         0 1 0 1 0 0 1 0 0 1  0  1  
         1 1 0 0 1 0 1 0 0 0  1  0  
         1 1 0 0 0 1 0 1 0 0  0  1  
         0 0 1 1 1 0 1 0 1 0  0  0  
         0 0 1 1 0 1 0 1 0 1  0  0];
    
    % Define nodes that make up each face
    F = [1  2  9
         1  9  5
         1  5  6
         1  6  10
         1  10 2
         2  7  9
         9  7  11
         9  11 5
         5  11 3
         5  3  6
         6  3  12
         6  12 10
         10 12 8
         10 8  2
         2  8  7
         4  7  8
         4  8  12
         4  12 3
         4  3  11
         4  11 7];
         
    % The icosahedron defined above is oriented so that an edge is at the
    % top. The following code transforms the vertex coordinates so that a
    % vertex is at the top to give a more conventional view.
    %
    % Define coordinate frame where z passes through one of the vertices and
    % transform the vertices so that one of the vertices is at the 'top'.
    Z = xyz(1,:)';   % Z passes through vertex 1
    X = xyz(2,:)';   % Choose adjacent vertex as an approximate X
    Y = cross(Z,X);  % Y is perpendicular to Z and this approx X
    X = cross(Y,Z);  % Final X is perpendicular to Y and Z
    X = X/norm(X); Y = Y/norm(Y); Z = Z/norm(Z);  % Ensure unit vectors
    xyz = ([X Y Z]'*xyz')';  % Transform points;