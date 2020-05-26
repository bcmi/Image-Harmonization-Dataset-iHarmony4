function Lab=i_xyz2lab(XYZ,IllObs)
%XYZ2LAB Convert from XYZ to LAB.
%   LAB=I_XYZ2LAB(XYZ,CWF) with size(XYZ)=[M 3] returns matrix LAB with
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
%      use XYZ2LAB instead.
%
%   Example:
%      i_xyz2lab([22 18 2], 'D50/2')
%
%   See also: XYZ2LAB, I_LAB2XYZ, MAKECWF, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_xyz2lab.m 24 2007-01-28 23:20:35Z jerkerw $

	white=wpt(IllObs);
	qXYZ=XYZ./white(ones(size(XYZ,1),1),:);

	ix = qXYZ(:,2)<=0.008856;

	Lab( ix,1) = 903.3 * qXYZ(ix,2);
	Lab(~ix,1) =  116  * qXYZ(~ix,2) .^ (1/3) - 16;

	Lab(:,2:3)=F(qXYZ) * [1 0;-1 1;0 -1] * diag([500 200]);

	% Make possible imaginary Nan's real Nan's

	Lab(isnan(Lab))=NaN;

function z=F(q)
	z=q.^(1/3);
	ix=q<=0.008856;
	z(ix)=7.787*q(ix)+16/116;
