function XYZ=i_luvp2xyz(Luvp,IllObs)
%I_LUVP2XYZ Convert from Lu'v' to XYZ.
%   XYZ=I_LUVP2XYZ(LUVP,CWF) with size(LUVP)=[M 3] returns
%   matrix XYZ with size [M N ... P 3].
%
%   CWF is a color weighting function specification. It can be a
%   string, e.g. 'D50/2', or a struct, see MAKECWF. If empty, the
%   the default cwf, OPTGETPREF('cwf') is used.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use LUVP2XYZ instead.
%
%   Example:
%         xyz=i_luvp2xyz([60 .3 .5],'D50/2')
%
%   See also: LUVP2XYZ, I_XYZ2LUVP, MAKECWF, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_luvp2xyz.m 24 2007-01-28 23:20:35Z jerkerw $

	XYZ=zeros(size(Luvp));
	wp=wpt(IllObs);
	qY=Luvp(:,1)/903.3;
	ix=qY>0.008856;
	qY(ix)=((Luvp(ix,1)+16)/116).^3;
	XYZ(:,2)=qY*wp(2);
	clear qY
	Mult=XYZ(:,2)/4/Luvp(:,3);
	XYZ(:,[1 3])=[9*Luvp(:,2) -(3*Luvp(:,2)+20*Luvp(:,3)-12)].*Mult(:,[1 1]);
