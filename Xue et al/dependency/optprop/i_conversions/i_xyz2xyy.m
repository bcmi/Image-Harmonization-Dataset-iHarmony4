function xyy=i_xyz2xyy(xyz)
%I_XYZ2XYY Convert from tristimulus XYZ to chromaticity xy and Y.
%   XYY=I_XYZ2XYY(XYZ) with size(XYZ)=[M 3] returns matrix XYY with
%   same size.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use XYZ2XYY instead.
%
%   See also: XYZ2XYY, I_XYY2XYZ

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_xyz2xyy.m 24 2007-01-28 23:20:35Z jerkerw $

	xyy=[i_xyz2xy(xyz) xyz(:,2)];
