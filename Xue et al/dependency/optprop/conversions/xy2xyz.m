function varargout=xy2xyz(varargin)
%XY2XYZ Convert from xy to XYZ with maximum Y.
%   XY2XYZ converts xy values to corresponding XYZ values, assuming
%   maximum Y, as defined by the Rösch color solid.
%
%   XYZ=XY2XYZ(XY,CWF) with size(XY)=[M N ... P 2] returns
%   matrix XYZ with size [M N ... P 3].
%
%   XYZ=XY2XYZ(X,Y,CWF) with size(X,Y)=[M N ... P] returns
%   matrix XYZ with size [M N ... P 3].
%
%   [X,Y,Z]=XY2XYZ(XY,CWF) with size(XY)=[M N ... P 2] returns
%   matrices X, Y and Z, each with size [M N ... P].
%
%   [X,Y,Z]=XY2XYZ(X,Y,CWF) with size(X,Y)=[M N ... P]
%   returns equally sized matrices X, Y and Z.
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%	Remark:
%   The algorithm used is not exact since an approximating algorithm is
%   used.
%
%   Example:
%      Visualize the colors of a circle in xy space around the D65/10
%      whitepoint:
%
%         n=100;
%         t=linspace(0,2*pi,n)';
%         xy=.05*[cos(t) sin(t)]+repmat(xyz2xy(wpt('D65/10')),n,1);
%         xyz=xy2xyz(xy);
%         rgb=xyz2rgb(xyz,'D65/10','srgb');
%         % Use surf to vary the color along a line
%         XY=repmat(reshape(xy,[1 n 2]),[2 1]);
%         Z=zeros([2 n 1]);
%         RGB=repmat(reshape(rgb,[1 n 3]),[2 1]);
%         h=surf(XY(:,:,1),XY(:,:,2),Z,RGB,'EdgeColor', 'interp', 'LineWidth', 4);
%         axis equal
%         view(2)
%         set(gca,'color','k');
%
%   See also: XYZ2XY, MAKECWF, OPTGETPREF, I_XY2XYZ

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: xy2xyz.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([2 0 1 0],1,@i_xy2xyz,varargin{:});
	error(err);

