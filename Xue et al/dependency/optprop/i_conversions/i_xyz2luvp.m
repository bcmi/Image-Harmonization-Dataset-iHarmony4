function Luvp=i_xyz2luvp(XYZ,IllObs)
%I_XYZ2LUVP Convert from XYZ to LU'V'.
%   LUVP=I_XYZ2LUVP(XYZ,CWF) with size(XYZ)=[M 3] returns matrix LUVP with
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
%      use XYZ2LUVP instead.
%
%   See also: XYZ2LUVP, I_LUVP2XYZ, MAKECWF, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_xyz2luvp.m 24 2007-01-28 23:20:35Z jerkerw $

	wp=wpt(IllObs);
	qY=XYZ(:,2)/wp(2);

	ix = qY<=0.008856;
	Luvp=zeros(size(XYZ));
	Luvp( ix,1) = 903.3 * qY(ix);
	Luvp(~ix,1) =  116  * qY(~ix) .^ (1/3) - 16;

	Denom=XYZ(:,1)+15*XYZ(:,2)+3*XYZ(:,3);
	ixz=Denom==0;
	ws=warning('off','MATLAB:divideByZero');
	Luvp(:,[2 3])=[4*XYZ(:,1) 9*XYZ(:,2)]./Denom(:,[1 1]);
	warning(ws);
	Luvp(ixz,[2 3])=0;
