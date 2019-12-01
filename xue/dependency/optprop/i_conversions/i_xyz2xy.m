function xy=i_xyz2xy(XYZ)
%XYZ2XY Convert from XYZ to chromaticity xy.
%   XY=I_XYZ2XY(XYZ) with size(XYZ)=[M 3] returns matrix XY with
%   size [M 2].
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use XYZ2XY instead.
%
%   See also: XYZ2XY, I_XY2XYZ, MAKECWF, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_xyz2xy.m 24 2007-01-28 23:20:35Z jerkerw $

	Denom=sum(XYZ,2);
	ws = warning('off', 'MATLAB:divideByZero');
	xy=XYZ(:,1:2)./Denom(:,[1 1]);
	warning(ws);
