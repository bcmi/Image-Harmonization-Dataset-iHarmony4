function XYZ=i_xyy2xyz(xyy)
%I_XYY2XYZ Converts from xyY to XYZ.
%   XYZ=I_XYY2XYZ(XYY) with size(XYY)=[M 3] returns matrix XYZ with
%   same size.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use XYY2XYZ instead.
%
%   See also: XYY2XYZ, I_XYZ2XYY, MAKECWF, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_xyy2xyz.m 24 2007-01-28 23:20:35Z jerkerw $

	Yxy=xyy(:,3)./xyy(:,2);
	XYZ=[xyy(:,[1 2]) 1-sum(xyy(:,[1 2]),2)].*Yxy(:,[1 1 1]);
