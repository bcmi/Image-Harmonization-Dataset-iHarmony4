function varargout=xyy2xyz(varargin)
%XYY2XYZ Converts from xyY to XYZ.
%   AXYZ=XYY2XYZ(XYY) with size(XYY)=[M N ... P 3] returns
%   matrix AXYZ with same size.
%
%   AXYZ=XYY2XYZ(CX,CY,Y) with size(CX,CY,Y)=[M N ... P] returns
%   matrix XYZ with size [M N ... P 3].
%
%   [AX,AY,AZ]=XYY2XYZ(XYY) with size(XYY)=[M N ... P 3] returns
%   matrices AX, AY and AZ, each with size [M N ... P].
%
%   [AX,AY,AZ]=XYY2XYZ(CX,CY,Y) with size(CX,CY,Y)=[M N ... P]
%   returns equally sized matrices AX, AY and AZ.
%
%   Example:
%      Convert the specification for sRGB xyY coordinates into XYZ:
%
%         spec=rgbs('srgb');
%         xyy2xyz(spec.xyy)
%
%   See also: XYZ2XYY, MAKECWF, OPTGETPREF, I_XYY2XYZ

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: xyy2xyz.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([3 0 0 0],[],@i_xyy2xyz,varargin{:});
	error(err);
