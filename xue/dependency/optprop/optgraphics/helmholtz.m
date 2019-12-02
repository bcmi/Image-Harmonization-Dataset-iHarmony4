function h=helmholtz(cwf, varargin)
%HELMHOLTZ Calculate and show  the Helmholtz "horseshoe"
%   HELMHOLTZ displays the chromaticity plot, with the whitepoint placed at
%   the chromaticity coordinates of the default illuminant/observer.
%
%   H=HELMHOLTZ displays as above and return the handle to the surface in H
%
%   ...=HELMHOLTZ(CWF), where CWF is a color weighting function specifica-
%   tion - string or struct, uses the white point of CWF, instead of the
%   default illuminant/observer.
%
%   ...=HELMHOLTZ(..., 'ShowZ', SHOWZ), where SHOWZ is boolean, plots also
%   z=1-x-y if SHOWZ is true. The default is SHOWZ=false, which renders all
%   z=0, i.e. the "horseshoe" is in the plane z=0.
%
%   Example:
%      helmholtz;       %plots a colorful helmholtz horseshoe

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: helmholtz.m 48 2007-03-28 10:53:48Z jerkerw $

	if nargin<1 || isempty(cwf);cwf=dcwf;end
	Defaults.ShowZ=false;
	params=args2struct(Defaults,varargin);

	[d,p]=meshgrid(450:5:680,linspace(0,1,20));
	xy=dp2xy(d,p,cwf);

	%
	% Make the grid thinner at both ends. The really don't contribute much
	% and the plot looks better, should anyone make the edges visible.
	%

	xy(:,[2 4 36 38 40:end-1],:)=[];

	% Close the surface
	xy=[xy xy(:,1,:)];

	C=xy2rgb(xy,cwf);
	if params.ShowZ
		z=1-xy(:,:,1)-xy(:,:,2);
	else
		z=zeros([size(xy,1) size(xy,2)]);
		end
	hh=surf(xy(:,:,1),xy(:,:,2),z,C ...
		,'FaceColor','interp', 'EdgeColor', 'none');
	if ~ishold && ~params.ShowZ
		view(2);
		end
	if nargout==1
		h=hh;
		end
