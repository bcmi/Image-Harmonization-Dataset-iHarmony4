function hv=viewgamut(varargin)
%VIEWGAMUT Visualize a color gamut
%   VIEWGAMUT creates a patch object based on matrix representation
%   of a color gamut. VIEWGAMUT(XYZ, C) with size(XYZ)=size(C)=[m n 3]
%   renders the surface XYZ with RGB values from C. The surface is closed
%   along the second dimension before it is rendered.
%
%   VIEWGAMUT(H, XYZ, C) assumes that H is previously rendered and merely
%   sets the new surface as faces and vertices. Useful for animations.
%
%   Example:
%      xyz=roo2xyz(rosch);
%      viewgamut(xyz,xyz2disp(xyz));
%
%   See also VIEWLAB

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: viewgamut.m 46 2007-03-28 08:52:17Z jerkerw $

	
	[ha,args] = handlecheck({'handle','surface','parent','axes'},varargin{:});
	if isempty(ha)
		hcmd={};
	elseif strcmp(get(ha, 'type'), 'axes')
		hcmd={'parent', ha};
	else
		hcmd={'handle', ha};
		end
	[err,h]=optproc([-3 1 0 inf],6,@i_viewgamut,args{:},hcmd{:});
	error(err);
	if nargout
		hv=h;
		end

function h=i_viewgamut(xyz,C,varargin)
	hs=[];
	[ha,args] = handlecheck({'handle','surface','parent','axes'},varargin{:});
	if isempty(ha)
		cax=newplot;
	elseif strcmp('axes',get(ha, 'type'))
		cax = newplot(ha);
	elseif strcmp('surface',get(ha, 'type'))
		hs = ha;
		end
	[xyz,C]=closesurf(xyz, 'Aux', C);

	if isempty(hs)
		hp=surface(xyz(:,:,1), xyz(:,:,2), xyz(:,:,3),rgbcast(C,'double'),args{:},'parent',cax);
		if ~ishold
			setprops(cax);
			end
	else
		set(hs ...
			,'XData',  xyz(:,:,1)...
			,'YData',  xyz(:,:,2)...
			,'ZData',  xyz(:,:,3)...
			,'CData',  rgbcast(C,'double') ...
			);
		hp=hs;
		end
	if nargout > 0
		h=hp;
		end

function setprops(cax)
	view(cax,3);
	axis(cax,'equal','vis3d');
	daspect(cax,[1 1 1]);
	grid(cax,'on');
