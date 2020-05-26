function Luv=i_xyz2luv(XYZ,IllObs)
%I_XYZ2LUV Convert from XYZ to LUV.
%   LUV=I_XYZ2LUV(XYZ,CWF) with size(XYZ)=[M 3] returns matrix LUV with
%   same size.
%
%   CWF is a color weighting function specification. It can be a
%   string, e.g. 'D50/2', or a struct, see MAKECWF. If empty, the
%   the default cwf, OPTGETPREF('cwf') is used.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use XYZ2LUV instead.
%
%   See also: XYZ2LUV, I_LUV2XYZ, MAKECWF, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_xyz2luv.m 32 2007-01-29 22:25:18Z jerkerw $

	Luv=i_xyz2luvp(XYZ,IllObs);
	wp=wpt(IllObs);
	Luvnp=i_xyz2luvp(wp,IllObs);
	Luv(:,2:3)=13*Luv(:,[1 1]).*(Luv(:,[2 3])-Luvnp(ones(size(Luv,1),1),[2 3]));
