function varargout=xy2rgb(varargin)
%XY2RGB Convert from XY to visually pleasing RGB.
%    XY2RGB converts xy values to corresponding RGB values, assuming
%    maximum Y, as defined by the Rösch color solid.
%
%   RGB=XY2RGB(XY,CWF,RGBTYPE) with size(XY)=[M N ... P 2] returns
%   matrix RGB with size [M N ... P 3].
%
%   RGB=XY2RGB(X,Y,CWF,RGBTYPE) with size(X,Y)=[M N ... P] returns
%   matrix RGB with size [M N ... P 3].
%
%   [R,G,B]=XY2RGB(XY,CWF,RGBTYPE) with size(XY)=[M N ... P 2] returns
%   matrices R, G and B, each with size [M N ... P].
%
%   [R,G,B]=XY2RGB(X,Y,CWF,RGBTYPE) with size(X,Y)=[M N ... P]
%   returns equally sized matrices R, G and B.
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%   RGBTYPE is one of the predefined RGB types or a conforming struct, see RGBS.
%   If omitted or empty, the default RGBTYPE, OPTGETPREF('WorkingRGB'), is used.
%
%   Example:
%      Visualize the colors of a circle in xy space around the whitepoint
%
%         n=100;
%         IllObs='D50/2';
%         t=linspace(0,2*pi,n)';
%         xy=.05*[cos(t) sin(t)]+repmat(xyz2xy(wpt(IllObs)),n,1);
%         rgb=xy2rgb(xy,IllObs,'srgb');
%         % Use surf to vary the color along a line
%         XY=repmat(reshape(xy,[1 n 2]),[2 1]);
%         Z=zeros([2 n 1]);
%         RGB=repmat(reshape(rgb,[1 n 3]),[2 1]);
%         h=surf(XY(:,:,1),XY(:,:,2),Z,RGB,'EdgeColor', 'interp', 'LineWidth', 4);
%         axis equal
%         view(2)
%         set(gca,'color','k');
%
%   See also: RGB2XY, MAKECWF, RGBS, OPTGETPREF, I_XY2RGB

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: xy2rgb.m 24 2007-01-28 23:20:35Z jerkerw $


	[err,varargout{1:max(1,nargout)}]=optproc([2 0 2 0],[1 4],@i_xy2rgb,varargin{:});
	error(err);
