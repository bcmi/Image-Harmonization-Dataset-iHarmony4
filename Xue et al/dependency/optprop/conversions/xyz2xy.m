function varargout=xyz2xy(varargin)
%XYZ2XY Convert from XYZ to chromaticity xy.
%   XY=XYZ2XY(XYZ) with size(XYZ)=[M N ... P 3] returns matrix XY with size
%   [M N ... P 2].
%
%   XY=XYZ2XY(X,Y,Z) with size(X,Y,Z)=[M N ... P] returns matrix XY with
%   size [M N ... P 2].
%
%   [AX,AY]=XYZ2XY(XYZ) with size(XYZ)=[M N ... P 3] returns matrices AX and
%   AY, each with size [M N ... P].
%
%   [AX,AY]=XYZ2XY(X,Y,Z) with size(X,Y,Z)=[M N ... P] returns equally sized
%   matrices AX and AY.
%
%    Example:
%       xyz2xy([50 50 50])
%
%   See also: XY2XYZ, I_XYZ2XY

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: xyz2xy.m 24 2007-01-28 23:20:35Z jerkerw $


	[err,varargout{1:max(1,nargout)}]=optproc([3 0 0 0],[],@i_xyz2xy,varargin{:});
	error(err);

	
