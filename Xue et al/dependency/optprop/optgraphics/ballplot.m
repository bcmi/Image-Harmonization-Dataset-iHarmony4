function varargout=ballplot(varargin)
%BALLPLOT 3-D spheres plot.
%   BALLPLOT(X,Y,Z,C,R) displays colored spheres at the locations specified
%   by the matrices X,Y,Z (which must all be the same size). The colors of
%   each sphere are based on the values in C and the radius of each sphere
%   is determined by the values in R (in axis coordinates).  R can be a
%   scalar, in which case all the spheres are drawn the same size, or a
%   vector the same length as prod(size(X)).
%   
%   When C is a vector the same length as prod(size(X)), the values in C
%   are linearly mapped to the colors in the current colormap.  
%   When C is a size(X)-by-3 matrix, the values in C specify the
%   colors of the markers as RGB values.  C can also be a color string.
%
%   BALLPLOT(X,Y,Z) draws the spheres with the default size and color.
%   BALLPLOT(X,Y,Z,C) draws the spheres with a default size.
%   BALLPLOT(X,Y,Z,C,R,F) draws the spheres having a roundness F. Increase
%      F in integer steps if the spheres looks crude. Default 1.
%
%   BALLPLOT(XYZ, ...), where XYZ is MxNx3, is in effect the same as
%      BALLPLOT(X,Y,Z, ...), where X, Y and Z are MxN
%
%   BALLPLOT(AX,...) plots into AX instead of GCA.
%
%   H = BALLPLOT(...) returns handles to scatter objects created.
%
%   Remarks:
%      Use PLOT3 for single color, single marker size 3-D scatter plots.
%
%      This routine still need some work, e.g. it doesn't handle different
%      scaling of x-, y- and z-axis, and it has some other rough edges, but
%      it is still quite useful.
%
%   Example:
%      [x,y,z] = sphere(8);
%	   
%      X = [x(:)*.5 x(:)*.75 x(:)];
%      Y = [y(:)*.5 y(:)*.75 y(:)];
%      Z = [z(:)*.5 z(:)*.75 z(:)];
%      C = repmat([1 2 3],numel(x),1);
%      ballplot(X,Y,Z,C(:));
%      view(-60,10)
%      camlight
%
%   See also SCATTER3, PLOT3.

% Part of the OptProp toolbox, $Version: 2.1 $
% Author: Jerker Wågberg, More Research & DPC, Sweden
% Email:  ['jerker.wagberg' char(64) 'more.se']

% $Id: ballplot.m 23 2007-01-28 22:55:34Z jerkerw $

	[cax,args] = axescheck(varargin{:});
	[err,varargout{1:nargout}]=optproc([-3 0 3 1],[6 6 6],@i_ballplot,args{:},'Parent', cax);
	error(err);

function h=i_ballplot(xyz,c,r,level,varargin)
	par=args2struct(struct('Parent', []), varargin);
	cax = newplot(par.Parent);
	if isempty(level); level=1; end
	if isempty(c);[ls,c]=nextstyle(cax);end

	xyz=reshape(xyz,[],3);
	[x,y,z]=deal(xyz(:,1),xyz(:,2),xyz(:,3));
	r=r(:);
	if ~isempty(r) && ~isscalar(r) && ~isequal(size(x),size(r))
		error(illpar('Illegal size of radius(es)'));
		end
	if numel(c)>1
		szc=size(c);
		c=reshape(c,[prod(szc(1:end-1)) szc(end)]);
		end
	% Map colors into colormap colors if necessary.
	if ischar(c)
		[c,msg]=ColorSpecToRGB(c);
		error(msg);
		end
	if isequal(size(c),[1 3]); % string color or scalar rgb
		C = repmat(c,length(x),1);
	elseif isvector(c) && length(x)==length(c)
		C=colormap(cax);
		mn=min(c);mx=max(c);
		if mx-mn==0
			C=C(round(length(C)/2),:);
		else
			C=C(floor((c-mn)/(mx-mn)*(length(C)-1))+1,:);
			end
	elseif isequal(size(c),[length(x) 3]), % vector of rgb's
		C = rgbcast(c,'uint8');
	else
		error(illpar(['C must be a single color, a vector the same length as X, ',...
				'or a size(X)-by-3 matrix.']));
		end

	if isempty(r)
		if ishold(cax)
			ax=axis(cax);
		else
			hf=figure('Visible', 'off');
			plot3(x,y,z,'.');
			axis tight;
			ax=axis;
%			da=daspect;
			delete(hf);
			end
		% Get length of shortest axis and make the radius 3% of that
		r=0.03*min(diff(reshape(ax,2,3)));
		end
	sz=size(C);
	C=reshape(C,prod(sz(1:end-1)),3);
	if size(C,1)==1
		C=repmat(C,[size(x,1) 1 1]);
		end
%	cax = newplot;
	next = lower(get(cax,'NextPlot'));
	hold_state = ishold(cax);
	np=size(x,1);
	fv=sphere_tri(level, 1);
	
	nv=size(fv.vertices,1);
	nf=size(fv.faces, 1);
	v=repmat(fv.vertices,[1 1 np]);
	if isscalar(r)
		r=repmat(r,[np 3]);
	elseif size(r,1)==1
		r=repmat(r,np,1);
	else
		r=repmat(r,1,3);
		end
	v=v.*repmat(reshape(r',[1 3 np]), [nv 1 1]);
	v=v+repmat(permute([x y z],[3 2 1]),[nv 1]);
	f=repmat(fv.faces, [1 1 np]) + repmat(reshape(nv*(0:np-1), [1 1 np]), [nf 3 1]);
	c=repmat(permute(C,[3 2 1]), [nf 1]);
	v = reshape(permute(v,[1 3 2]),[],3);
	f = reshape(permute(f,[1 3 2]),[],3);
	c = reshape(permute(c,[1 3 2]),[],3);

 	hh=patch( ...
 		  'vertices', v, 'faces', f, 'FaceVertexCData', rgbcast(c, 'double') ...
 		, 'facecolor', 'flat' ...
 		, 'edgecolor'	, 'none' ...
		, 'parent', cax ...
 		);
	if ~hold_state
		set(ancestor(cax,'figure'),'Renderer', 'OpenGL');
		axis(cax,'equal','tight');
		if any(diff(z))
			view(cax,3)
			axis(cax,'vis3d');
		else
			view(cax,2)
			end
		grid(cax);
		set(cax,'NextPlot',next);
		end
	if 1<=nargout
		h=hh;
		end

function [color,msg] = ColorSpecToRGB(s)
	color=[];
	msg = [];
	switch s
		case 'y'
			color = [1 1 0];
		case 'm'
			color = [1 0 1];
		case 'c'
			color = [0 1 1];
		case 'r'
			color = [1 0 0];
		case 'g'
			color = [0 1 0];
		case 'b'
			color = [0 0 1];
		case 'w'
			color = [1 1 1];
		case 'k'
			color = [0 0 0];
		otherwise
			msg = 'unrecognized color string';
		end

function FV = sphere_tri(maxlevel,r)
% sphere_tri - generate a triangle mesh approximating a sphere
% 
% Usage: FV = sphere_tri(shape,Nrecurse,r,winding)
% 
%   Nrecurse is int >= 0, setting the recursions (default 0)
%
%   r is the radius of the sphere (default 1)
%
%   FV has fields FV.vertices and FV.faces.  The vertices 
%   are listed in clockwise order in FV.faces, as viewed 
%   from the outside in a RHS coordinate system.
% 
% The function uses recursive subdivision.  The first
% approximation is an platonic icosahedron.  Each level of 
% refinement subdivides each triangle face by a factor of 4
% (see also mesh_refine). At each refinement, the vertices are 
% projected to the sphere surface (see sphere_project).
% 
% A recursion level of 3 or 4 is a good sphere surface, if
% gouraud shading is used for rendering.
% 
% The returned struct can be used in the patch command, eg:
% 
% % create and plot, vertices: [2562x3] and faces: [5120x3]
% FV = sphere_tri(',4,1);
% lighting phong; shading interp; figure;
% patch('vertices',FV.vertices,'faces',FV.faces,...
%       'facecolor',[1 0 0],'edgecolor',[.2 .2 .6]);
% axis off; camlight infinite; camproj('perspective');
% 
% See also: mesh_refine, sphere_project
%

% $Revision: 1.15 $ $Date: 2004/05/20 22:28:45 $

% Licence:  GNU GPL, no implied or express warranties
% Jon Leech (leech @ cs.unc.edu) 3/24/89
% icosahedral code added by Jim Buddenhagen (jb1556@daditz.sbc.com) 5/93
% 06/2002, adapted from c to matlab by Darren.Weber_at_radiology.ucsf.edu
% 05/2004, reorder of the faces for the 'ico' surface so they are indeed
% clockwise!  Now the surface normals are directed outward.  Also reset the
% default recursions to zero, so we can get out just the platonic solids.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


	% Twelve vertices of icosahedron on unit sphere
	tau = 0.8506508084; % t=(1+sqrt(5))/2, tau=t/sqrt(1+t^2)
	one = 0.5257311121; % one=1/sqrt(1+t^2) , unit sphere

	FV.vertices = [
			 tau,  one,    0
			-tau,  one,    0
			-tau, -one,    0
			 tau, -one,    0
			 one,   0 ,  tau
			 one,   0 , -tau
			-one,   0 , -tau
			-one,   0 ,  tau
			  0 ,  tau,  one
			  0 , -tau,  one
			  0 , -tau, -one
			  0 ,  tau, -one
			];
		% Structure for unit icosahedron
		FV.faces = [  5,  8,  9 ;
				   5, 10,  8 ;
				   6, 12,  7 ;
				   6,  7, 11 ;
				   1,  4,  5 ;
				   1,  6,  4 ;
				   3,  2,  8 ;
				   3,  7,  2 ;
				   9, 12,  1 ;
				   9,  2, 12 ;
				  10,  4, 11 ;
				  10, 11,  3 ;
				   9,  1,  5 ;
				  12,  6,  1 ;
				   5,  4, 10 ;
				   6, 11,  4 ;
				   8,  2,  9 ;
				   7, 12,  2 ;
				   8, 10,  3 ;
				   7,  3, 11 ];

	% -----------------
	% refine the starting shapes with subdivisions
	if maxlevel
		% Subdivide each starting triangle (maxlevel) times
		for level = 1:maxlevel,

			% Subdivide each triangle and normalize the new points thus
			% generated to lie on the surface of a sphere radius r.
			FV = mesh_refine_tri4(FV);
			FV.vertices = sphere_project(FV.vertices,r);

			% An alternative might be to define a min distance
			% between vertices and recurse or use fminsearch

			end
		end

function [ FV ] = mesh_refine_tri4(FV)

% mesh_refine_tri4 - creates 4 triangle from each triangle of a mesh
%
% [ FV ] = mesh_refine_tri4( FV )
%
% FV.vertices   - mesh vertices (Nx3 matrix)
% FV.faces      - faces with indices into 3 rows
%                 of FV.vertices (Mx3 matrix)
% 
% For each face, 3 new vertices are created at the 
% triangle edge midpoints.  Each face is divided into 4
% faces and returned in FV.
%
%        B
%       /\
%      /  \
%    a/____\b       Construct new triangles
%    /\    /\       [A,a,c]
%   /  \  /  \      [a,B,b]
%  /____\/____\     [c,b,C]
% A	     c	   C    [a,b,c]
% 
% It is assumed that the vertices are listed in clockwise order in
% FV.faces (A,B,C above), as viewed from the outside in a RHS coordinate
% system.
% 
% See also: mesh_refine, sphere_tri, sphere_project
% 


% ---this method is not implemented, but the idea here remains...
% This can be done until some minimal distance (D) of the mean 
% distance between vertices of all triangles is achieved.  If
% no D argument is given, the function refines the mesh once.
% Alternatively, it could be done until some minimum mean 
% area of faces is achieved.  As is, it just refines once.


% $Revision: 1.12 $ $Date: 2004/05/10 21:01:55 $

% Licence:  GNU GPL, no implied or express warranties
% History:  05/2002, Darren.Weber_at_radiology.ucsf.edu, created
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NOTE
% The centroid is located one third of the way from each vertex to 
% the midpoint of the opposite side. Each median divides the triangle 
% into two equal areas; all the medians together divide it into six 
% equal parts, and the lines from the median point to the vertices 
% divide the whole into three equivalent triangles.

% Each input triangle with vertices labelled [A,B,C] as shown
% below will be turned into four new triangles:
%
% Make new midpoints
% a = (A+B)/2
% b = (B+C)/2
% c = (C+A)/2
%
%        B
%       /\
%      /  \
%    a/____\b       Construct new triangles
%    /\    /\       [A,a,c]
%   /  \  /  \      [a,B,b]
%  /____\/____\     [c,b,C]
% A	     c	   C    [a,b,c]
%

% Initialise a new vertices and faces matrix
%Nvert = size(FV.vertices,1);
Nface = size(FV.faces,1);
%V2 = zeros(Nface*3,3);
F2 = zeros(Nface*4,3);

for f = 1:Nface,
    
    % Get the triangle vertex indices
    NA = FV.faces(f,1);
    NB = FV.faces(f,2);
    NC = FV.faces(f,3);
    
    % Get the triangle vertex coordinates
    A = FV.vertices(NA,:);
    B = FV.vertices(NB,:);
    C = FV.vertices(NC,:);
    
    % Now find the midpoints between vertices
    a = (A + B) ./ 2;
    b = (B + C) ./ 2;
    c = (C + A) ./ 2;
    
    % Find the length of each median
    %A2blen = sqrt ( sum( (A - b).^2, 2 ) );
    %B2clen = sqrt ( sum( (B - c).^2, 2 ) );
    %C2alen = sqrt ( sum( (C - a).^2, 2 ) );
    
    % Store the midpoint vertices, while
    % checking if midpoint vertex already exists
    [FV, Na] = mesh_find_vertex(FV,a);
    [FV, Nb] = mesh_find_vertex(FV,b);
    [FV, Nc] = mesh_find_vertex(FV,c);
    
    % Create new faces with orig vertices plus midpoints
    F2(f*4-3,:) = [ NA, Na, Nc ];
    F2(f*4-2,:) = [ Na, NB, Nb ];
    F2(f*4-1,:) = [ Nc, Nb, NC ];
    F2(f*4-0,:) = [ Na, Nb, Nc ];
    
end

% Replace the faces matrix
FV.faces = F2;

return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [FV, N] = mesh_find_vertex(FV,vertex)

    Vn = size(FV.vertices,1);
    Va = repmat(vertex,Vn,1);
    Vexist = find( FV.vertices(:,1) == Va(:,1) & ...
                   FV.vertices(:,2) == Va(:,2) & ...
                   FV.vertices(:,3) == Va(:,3) );
    if Vexist,
        if isscalar(Vexist)
            N = Vexist;
        else
            error('replicated vertices');
        end
    else
        FV.vertices(end+1,:) = vertex;
        N = size(FV.vertices,1);
    end

return

function V = sphere_project(v,r,c)

% sphere_project - project point X,Y,Z to the surface of sphere radius r
% 
% V = sphere_project(v,r,c)
% 
% Cartesian inputs:
% v is the vertex matrix, Nx3 (XYZ)
% r is the sphere radius, 1x1 (default 1)
% c is the sphere centroid, 1x3 (default 0,0,0)
%
% XYZ are converted to spherical coordinates and their radius is
% adjusted according to r, from c toward XYZ (defined with theta,phi)
% 
% V is returned as Cartesian 3D coordinates
% 

% $Revision: 1.8 $ $Date: 2004/03/29 21:15:36 $

% Licence:  GNU GPL, no implied or express warranties
% History:  06/2002, Darren.Weber_at_radiology.ucsf.edu, created
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('v','var'),
    error('SPHERE_PROJECT: No input vertices (X,Y,Z)');
end

X = v(:,1);
Y = v(:,2);
Z = v(:,3);

if ~exist('c','var'),
    xo = 0;
    yo = 0;
    zo = 0;
else
    xo = c(1);
    yo = c(2);
    zo = c(3);
end

if ~exist('r','var'), r = 1; end

% alternate method is to use unit vector of V
% [ n = 'magnitude(V)'; unitV = V ./ n; ]
% to change the radius, multiply the unitV
% by the radius required.  This avoids the
% use of arctan functions, which have branches.


% Convert Cartesian X,Y,Z to spherical (radians)
theta = atan2( (Y-yo), (X-xo) );
phi   = atan2( sqrt( (X-xo).^2 + (Y-yo).^2 ), (Z-zo) );
% do not calc: r = sqrt( (X-xo).^2 + (Y-yo).^2 + (Z-zo).^2);

%   Recalculate X,Y,Z for constant r, given theta & phi.
R = ones(size(phi)) * r;
x = R .* sin(phi) .* cos(theta);
y = R .* sin(phi) .* sin(theta);
z = R .* cos(phi);

V = [x y z];

return

