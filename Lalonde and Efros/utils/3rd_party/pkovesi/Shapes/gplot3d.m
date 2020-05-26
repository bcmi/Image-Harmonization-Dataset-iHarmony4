function [Xout,Yout,Zout]=gplot3d(A,xyz,lc)
%GPLOT3D Plot graph, as in "graph theory".
%   This is a modification of MATLAB's GPLOT function for vertices in 3D.
%   GPLOT3D(A,xyz) plots the graph specified by A and xyz. A graph, G, is
%   a set of nodes numbered from 1 to n, and a set of connections, or
%   edges, between them.  
%
%   In order to plot G, two matrices are needed. The adjacency matrix,
%   A, has a(i,j) nonzero if and only if node i is connected to node
%   j.  The coordinates array, xyz, is an n-by-3 matrix with the
%   position for node i in the i-th row, xyz(i,:) = [x(i) y(i) z(i)].
%   
%   GPLOT(A,xyz,LineSpec) uses line type and color specified in the
%   string LineSpec. See PLOT for possibilities.
%
%   [X,Y] = GPLOT(A,xyz) returns the NaN-punctuated vectors
%   X and Y without actually generating a plot. These vectors
%   can be used to generate the plot at a later time if desired. As a
%   result, the two argument output case is only valid when xyz is of type
%   single or double.
%    
%   This code is MATLAB's GPLOT function modified so that it plots a graph
%   where the vertices are defined in 3D    
%   
%   See also SPY, TREEPLOT, GPLOT
%

%   John Gilbert
%   Copyright 1984-2009 The MathWorks, Inc. 
%   $Revision: 5.12.4.4 $  $Date: 2009/04/21 03:26:12 $
%
%   3D modifications by Peter Kovesi 
%   peter.kovesi at uwa edu au    

[i,j] = find(A);
[~, p] = sort(max(i,j));
i = i(p);
j = j(p);

X = [ xyz(i,1) xyz(j,1)]';
Y = [ xyz(i,2) xyz(j,2)]';
Z = [ xyz(i,3) xyz(j,3)]';

if isfloat(xyz) || nargout ~= 0
    X = [X; NaN(size(i))'];
    Y = [Y; NaN(size(i))'];
    Z = [Z; NaN(size(i))'];    
end

if nargout == 0
    if ~isfloat(xyz)
        if nargin < 3
            lc = '';
        end
        [lsty, csty, msty] = gplotGetRightLineStyle(gca,lc);    
        plot3(X,Y,Z,'LineStyle',lsty,'Color',csty,'Marker',msty);
    else
        if nargin < 3
            plot3(X(:),Y(:),Z(:));
        else
            plot3(X(:),Y(:),Z(:),lc);
        end
    end
else
    Xout = X(:);
    Yout = Y(:);
    Zout = Z(:);    
end

function [lsty, csty, msty] = gplotGetRightLineStyle(ax, lc)
%  gplotGetRightLineStyle
%    Helper function which correctly sets the color, line style, and marker
%    style when plotting the data above.  This style makes sure that the
%    plot is as conformant as possible to gplot from previous versions of
%    MATLAB, even when the coordinates array is not a floating point type.
co = get(ax,'ColorOrder');
lo = get(ax,'LineStyleOrder');
holdstyle = getappdata(gca,'PlotHoldStyle');
if isempty(holdstyle)
    holdstyle = 0;
end
lind = getappdata(gca,'PlotLineStyleIndex');
if isempty(lind) || holdstyle ~= 1
    lind = 1;
end
cind = getappdata(gca,'PlotColorIndex');
if isempty(cind) || holdstyle ~= 1
    cind = 1;
end
nlsty = lo(lind);
ncsty = co(cind,:);
nmsty = 'none';
%  Get the linespec requested by the user.
[lsty,csty,msty] = colstyle(lc);
if isempty(lsty)
    lsty = nlsty;
end
if isempty(csty)
    csty = ncsty;
end
if isempty(msty)
    msty = nmsty;
end
