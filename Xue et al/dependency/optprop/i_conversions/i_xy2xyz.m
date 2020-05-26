function xyz=i_xy2xyz(xy,IllObs)
%I_XY2XYZ Convert from xy to XYZ with maximum Y.
%   I_XY2XYZ converts xy values to corresponding XYZ values, assuming
%   maximum Y, as defined by the Rösch color solid.
%
%   XYZ=I_XY2XYZ(XY,CWF) with size(XY)=[M 2] returns matrix XYZ with
%   size [M 3].
%
%   CWF is a color weighting function specification. It can be a
%   string, e.g. 'D50/2', or a struct, see MAKECWF. If empty, the
%   the default cwf, OPTGETPREF('cwf') is used.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use XY2XYZ instead.
%
%   See also: XY2XYZ, I_XYZ2XY, MAKECWF, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_xy2xyz.m 24 2007-01-28 23:20:35Z jerkerw $

	persistent Yi
	persistent SavedIllObs

	n=100;
	xi=linspace(-.1,.8,n);
	yi=linspace(0,.85,n)';
	if isempty(Yi) || ~isequal(IllObs, SavedIllObs)
		% Get the XYZ values for the Rosch volume without any NaNs
		lam=400:10:700;
		xyz=roo2xyz(rosch(length(lam),'Align',false), IllObs,lam);
		% Save one of the whites
		w=reshape(xyz(1,end,:),1,3);
		% Take away all blacks, all whites and one duplicate row, reshape,
		% put back the white
		xyz=[reshape(xyz(2:end,2:end-1,:),[],3); w];
		sxy=xyz2xy(xyz);
		Yi=gridfit(sxy(:,1),sxy(:,2),xyz(:,2),xi,yi,'smooth',.5);
		SavedIllObs = IllObs;
		end
	Y=interp2(xi,yi,Yi,xy(:,1),xy(:,2),'*cubic');
	xyz=i_xyy2xyz([xy Y]);
	
