function Lab=i_luv2lab(Luv,IllObs)
%I_LUV2LAB Convert from LUV to LAB.
%   LAB=I_LUV2LAB(LUV,CWF) with size(LUV)=[M 3] returns
%   matrix LAB with same size.
%
%   CWF is a color weighting function specification. It can be a
%   string, e.g. 'D50/2', or a struct, see MAKECWF. If empty, the
%   the default cwf, OPTGETPREF('cwf') is used.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use LUV2LAB instead.
%
%   Example:
%      i_luv2lab([60 80 30], 'D50/2')
%
%   See also: LUV2LAB, I_LAB2LUV, MAKECWF, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_luv2lab.m 24 2007-01-28 23:20:35Z jerkerw $

	Lab=i_xyz2lab(i_luv2xyz(Luv,IllObs), IllObs);
