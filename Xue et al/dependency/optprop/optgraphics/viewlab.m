function hv=viewlab(varargin)
%VIEWLAB Visualize an Lab color gamut
%   VIEWLAB creates a surface object based on matrix representation of an Lab
%   color gamut.
%
%   H=VIEWLAB(LAB) with size(LAB)=[m n 3] renders the surface LAB with
%   corresponding RGB values and returns its handle in H. The surface is
%   closed along the second dimension before it is rendered. LAB is
%   permuted to render L in the z-direction.
%
%   H=VIEWLAB(L,A,B) with equally sized L, A and B, [M N], renders the same
%   image as VIEWLAB(CAT(3,L,A,B)).
%
%   VIEWLAB(LAB,C) or VIEWLAB(L,A,B,C) with C same size as LAB, [M,N,3],
%   assumes that C is a color specification in OPTGETPREF('DisplayRGB')
%   space, and will render with these colors.
%
%   VIEWLAB(H, ...) with surface handle H, assumes that H is a previously
%   rendered gamut and merely sets the new surface as faces and vertices.
%   Useful for animations.
%
%   VIEWLAB(HAX, ...) with axes handle HAX, will render the gamut in axes
%   HAX instead of the default GCA.
%
%   ...=VIEWLAB(..., 'PropertyName', PropertyValue,...) forwards the P/V
%   list to the surface.
%
%   Example:
%      lab=roo2lab(rosch);
%      viewlab(lab, 'EdgeColor', 'none');
%
%   See also VIEWGAMUT

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: viewlab.m 23 2007-01-28 22:55:34Z jerkerw $

	[ha,args] = handlecheck({'handle','surface','parent','axes'},varargin{:});
	if isempty(ha)
		hcmd={};
	elseif strcmp(get(ha, 'type'), 'axes')
		hcmd={'parent', ha};
	else
		hcmd={'handle', ha};
		end
	[err,h]=optproc([-3 0 2 inf],[6 1],@i_viewlab,args{:},hcmd{:});
	error(err);
	if nargout
		hv=h;
		end

function h=i_viewlab(lab,C,cwf,varargin)
	if isempty(C)
		C=lab2disp(lab, cwf);
		end
	h=viewgamut(lab(:,:,[2 3 1]), C, varargin{:});
