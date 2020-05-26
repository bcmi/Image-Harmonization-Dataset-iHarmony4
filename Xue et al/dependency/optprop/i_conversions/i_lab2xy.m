function xy=i_lab2xy(Lab,cwf)
%I_LAB2XY Convert from Lab to chromaticity coordinates x and y.
%   XY=I_LAB2XY(LAB,CWF) with size(LAB)=[M 3] returns
%   matrix XY with size [M N ... P 2].
%
%   CWF is a color weighting function specification. It can be a
%   string, e.g. 'D50/2', or a struct, see MAKECWF. If empty, the
%   the default cwf, OPTGETPREF('cwf') is used.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use LAB2XY instead.
%
%   Example:
%      Verify that pure grays have the same chromaticity.
%
%         xy=i_lab2xy([25 0 0;50 0 0;75 0 0;100 0 0],'D65/10')
%
%   See also: LAB2XY, I_XY2LAB, MAKECWF, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_lab2xy.m 24 2007-01-28 23:20:35Z jerkerw $

	xy=i_xyz2xy(i_lab2xyz(Lab, cwf));
