function XYZ=i_luv2xyz(Luv,IllObs)
%I_LUV2XYZ Convert from Luv to XYZ.
%   XYZ=I_LUV2XYZ(LUV,CWF) with size(LUV)=[M 3] returns
%   matrix XYZ with same size.
%
%   CWF is a color weighting function specification. It can be a
%   string, e.g. 'D50/2', or a struct, see MAKECWF. If empty, the
%   the default cwf, OPTGETPREF('cwf') is used.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use LUV2XYZ instead.
%
%   Example:
%      i_luv2xyz([30 40 50],'D65/2')
%
%   See also: LUV2XYZ, I_XYZ2LUV, MAKECWF, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_luv2xyz.m 24 2007-01-28 23:20:35Z jerkerw $

	wp=wpt(IllObs);
	Luvnp=i_xyz2luvp(wp,IllObs);
	% Luv now in reality becomes Lu'v'
	ws=warning('off','MATLAB:divideByZero');
	Luv=[Luv(:,1) Luv(:,[2 3])/13./Luv(:,[1 1])+Luvnp(ones(size(Luv,1),1),[2 3])];
	XYZ=i_luvp2xyz(Luv,IllObs);
	warning(ws);
	XYZ(isnan(XYZ))=0;
