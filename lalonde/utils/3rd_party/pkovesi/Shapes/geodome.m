% GEODOME   Generates geodesic sphere 
%
% Usage:  [xyz, A, F] = geodome(frequency, radius)
%
% The sphere is generated from subdivisions of the faces of an icosahedron.
%
% Arguments: 
%        frequency - The number of subdivisions of each edge of an
%                    icosahedron.  A frequency of 1 will give you an
%                    icosahedron. A high number will give you a more
%                    spherical shape. Defaults to 2.
%           radius - Radius of the sphere. Defaults to 1.
% Returns:
%              xyz - A nx3 matrix defining the vertex list, each row is the
%                    x,y,z coordinates of a vertex.
%                A - Adjacency matrix defining the connectivity of the
%                    vertices
%                F - A mx3 matrix defining the face list.  Each row of F
%                    specifies the 3 vertices that make up the face.
%
% Example:
%    [xyz, A, F] = geodome(3, 5);  % Generate a 3-frequency sphere with
%                                  % radius 5
%    gplot3d(A, xyz);              % Use adjacency matrix and vertex list to
%                                  % generate a wireframe plot.
%    drawfaces(xyz, F);            % Use face and vertex lists to generate
%                                  % surface patch plot.
%    axis vis3d, axis off, rotate3d on
%
% See also: ICOSAHEDRON, GPLOT3D, DRAWFACES

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

function [xyz, A, F] = geodome(frequency, radius)

    if ~exist('frequency','var')
        frequency = 2;
    end

    if ~exist('radius','var')
        radius = 1;
    end
    
    if frequency < 1
        error('Frequency must be an integer >= 1');
    end
    
    % Generate vertices of base icosahedron
    [icosXYZ, icosA, icosF] = icosahedron(1);
    
    % Compute number of vertices in geodesic sphere.  This is the 12 vertices
    % of the icosahedron + the extra vertices introduced on each of the 30
    % edges + the extra vertices in the interior of the of each of the 20
    % faces.  This latter is a sum of an arithmetic series [1 .. (frequency-2)]
    fm1 = frequency - 1;
    fm2 = frequency - 2;    
    nVert = 12 + 30*fm1 + 20*fm2*fm1/2;
    
    xyz = zeros(nVert,3);
    
    if frequency == 1             % Just return the icosahedron
        xyz = icosXYZ;
        A = icosA;
        F = icosF;
    else                          % For all frequencies > 1
        xyz(1:12,:) = icosXYZ;    % Grab the vertices of the icosahedron
        offset = 13;

        % Find the nodes that connect edges.  Note we use the upper triangular
        % part of the adjacency matrix so that we only get each edge once.
        [i,j] = find(triu(icosA));

        % Generate extra vertices on every edge of the icoshedron.
        for n = 1:length(i)
            xyz(offset:(offset+fm2) ,:) = ...
                   divideEdge(icosXYZ(i(n),:), icosXYZ(j(n),:), frequency);
            offset = offset+fm1;
        end
        
        % Generate the extra vertices within each face of the icoshedron.
        for f = 1:length(icosF)  
            
            % Re subdivide two of the edges of the face and get the vertices
            % (Yes, this is wasteful but it makes code logic easier)
            V1 = divideEdge(icosXYZ(icosF(f,1),:), icosXYZ(icosF(f,2),:), frequency);
            V2 = divideEdge(icosXYZ(icosF(f,1),:), icosXYZ(icosF(f,3),:), frequency);            

            % Now divide the edges that join the new vertices along the
            % subdivided edges.
            for v = 2:fm1
               VF = divideEdge(V1(v,:), V2(v,:), v);
               xyz(offset:(offset+v-2),:) = VF;
               offset = offset+v-1;
            end
        end
    
    end

    xyx = xyz*radius;       % Scale vertices to required radius
    A = adjacency(xyz);
    F = faces(A);

%---------------------------------------------------------------------
% Function to divide an edge defined between vertices V1 and V2 into nSeg
% segments and return the coordinates of the vertices.
% This function simplistically divides the distance between V1 and V2

function vert = divideEdgeOld(V1, V2, nSeg)

    edge = V2 - V1;  % Vector along edge

    % Now add appropriate fractions of the edge length to the first node
    vert = zeros(nSeg-1, 3);
    for f = 1:(nSeg-1)
        vert(f,:) = V1 + edge * f/nSeg;
        vert(f,:) = vert(f,:)/norm(vert(f,:));   % Normalize to unit length
    end


%---------------------------------------------------------------------
% Function to divide an edge defined between vertices V1 and V2 into nSeg
% segments and return the coordinates of the vertices.
% This function divides the *angle* between V1 and V2
% rather than the distance.
function vert = divideEdge(V1, V2, nSeg)

    axis = cross(V1,V2); 
    angle = atan(norm(axis)/dot(V1,V2));
    axis = axis/norm(axis);
    
    % Now add appropriate fractions of the edge length to the first node
    vert = zeros(nSeg-1, 3);
    for f = 1:(nSeg-1)
        Q = newquaternion(f*angle/nSeg, axis);
        vert(f,:) =  quaternionrotate(Q,V1);
        vert(f,:) = vert(f,:)/norm(vert(f,:));   % Normalize to unit length
    end

    
    
%-------------------------------------------------------------------------
% Function to build adjacency matrix for geodesic sphere by brute force
    
function A = adjacency(xyz)
    
    nVert = length(xyz);
    A = zeros(nVert);

    % Find distances between all pairs of vertices    
    for n1 = 1:nVert-1
        A(n1,n1) = Inf;
        for n2 = n1+1:nVert
            A(n1,n2) = norm(xyz(n2,:) - xyz(n1,:));
        end
    end
    A(nVert,nVert) = Inf;
    
    A = A+A';   % Make A symmetric
    
    % Find min distance in first row.  
    minD = min(A(1,:)');

    % Assume that no edge can be more than 1.5 times this minimum distance, use
    % this to decide connectivity of nodes.
    A = A < minD*1.5;

%-----------------------------------------------------------------------------
% Function to find the triplets of vertices that define the faces of the
% geodesic sphere

function  F = faces(A)
    
    % Strategy:  We are only after cycles of length 3 in graph defined by A.
    % For every node N0 (except the last two, which we will not need to visit)
    % - Get list of neighbours, N1
    % - For each neighbour N1i in N1 find its list of neighbours, N2.
    % - Any neighbour in N2 that is in N1 must form a cycle of length 3 with N0
        
    nVert = length(A);
    F = [];
 
    for N0 = 1:nVert-2
        N1 = find(A(N0,:));            % Neighbours of N0
        for N1i = N1              
            N2 = find(A(N1i,:));    
            cycle = intersect(N2,N1);  % Find the 2 nodes of N2 that are in N1
            F = [F; [N0 N1i cycle(1)]; [N0 N1i cycle(2)]];
        end
    end
    
    % Each face will be found multiple times, eliminate duplicates.  
    F = sort(F,2);            % Sort rows of face list
    F = unique(F,'rows');     % ...then extract the unique rows.