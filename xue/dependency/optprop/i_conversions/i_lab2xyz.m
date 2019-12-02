function XYZ=i_lab2xyz(Lab,IllObs)
%I_LAB2XYZ Convert from Lab to XYZ.
%   XYZ=I_LAB2XYZ(LAB,CWF) with size(LAB)=[M 3] returns
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
%      use LAB2XYZ instead.
%
%   Example:
%      Verify that Lab=[100 0 0] corresponds to the whitepoint
%
%         xyz=i_lab2xyz([100 0 0],'D65/10');
%         white=wpt('D65/10');
%         disp(white-xyz)
%
%   See also: LAB2XYZ, I_XYZ2LAB, MAKECWF, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_lab2xyz.m 24 2007-01-28 23:20:35Z jerkerw $

	qY=Lab(:,1)/903.3;
	ix=qY>0.008856;
	qY(ix)=((Lab(ix,1)+16)/116).^3;
	qXZ=InvF([Lab(:,2)/500+F(qY) F(qY)-Lab(:,3)/200]);

	N=wpt(IllObs);
	XYZ = [qXZ(:,1)*N(1) qY*N(2) qXZ(:,2)*N(3)];
	XYZ(isnan(XYZ))=NaN;

function z=F(q)
	z=zeros(size(q));
	ix=q<=0.008856;
	z(ix)=7.787*q(ix)+16/116;
	z(~ix)=q(~ix).^(1/3);

function z=InvF(q)
	z=(q-16/116)/7.787;
	ix=z>0.008856;
	z(ix)=q(ix).^3;
