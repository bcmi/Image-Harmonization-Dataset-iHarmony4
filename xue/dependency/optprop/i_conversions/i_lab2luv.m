function Luv=i_lab2luv(Lab,cwf)
%LAB2LUV Convert from Lab to Luv.
%   LUV=I_LAB2LUV(LAB,CWF) with size(LAB)=[M 3] returns
%   matrix LUV with same size.
%
%   CWF is a color weighting function specification. It can be a
%   string, e.g. 'D50/2', or a struct, see MAKECWF. If empty, the
%   the default cwf, OPTGETPREF('cwf') is used.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use LAB2LUV instead.
%
%   Example:
%      i_lab2luv([30 40 50],'D50/2')
%
%   See also: LAB2LUV, I_LUV2LAB, MAKECWF, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_lab2luv.m 24 2007-01-28 23:20:35Z jerkerw $

	Luv=i_xyz2luv(i_lab2xyz(Lab,cwf), cwf);
