function varargout=xyz2xyy(varargin)
%XYZ2XYY Convert from tristimulus XYZ to chromaticity xy and Y
%   XYY=XYZ2XYY(XYZ) with size(XYZ)=[M N ... P 3] returns
%   matrix XYY with same size.
%
%   XYY=XYZ2XYY(X,Y,Z) with size(X,Y,Z)=[M N ... P] returns
%   matrix XYY with size [M N ... P 3].
%
%   [CX,CY,YY]=XYZ2XYY(XYZ) with size(XYZ)=[M N ... P 3] returns
%   matrices CX, CY and YY, each with size [M N ... P].
%
%   [CX,CY,YY]=XYZ2XYY(X,Y,Z) with size(X,Y,Z)=[M N ... P]
%   returns equally sized matrices CX, CY and YY.
%
%   Example:
%      xyy=xyz2xyy([10 30 20])
%
%   See also: XYY2XYZ, I_XYZ2XYY

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: xyz2xyy.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([3 0 0 0],[],@i_xyz2xyy,varargin{:});
	error(err);

