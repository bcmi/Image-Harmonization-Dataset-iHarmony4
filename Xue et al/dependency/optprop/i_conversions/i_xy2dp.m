function DP=i_xy2dp(xyi,IllObs)
%I_XY2DP Calculate dominating wavelength and exitation purity.
%   DP=I_XY2DP(XY,CWF) with size(XY)=[M 2] returns matrix DP with
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
%      use XY2DP instead.
%
%   See also: XY2DP, I_DP2XY, MAKECWF, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_xy2dp.m 24 2007-01-28 23:20:35Z jerkerw $

	VISUALIZE=0;
	xyo=i_xyz2xy(wpt(IllObs));
	[xyz,lam]=observer(cwf2obs(IllObs));
	xy=i_xyz2xy(xyz);
	low=ceil(size(xyz,1)/2);
	RealHigh=low-1+find(sqrt(sum(diff(xyz(low:end,1:2)).^2,2))< 1e-5,1);
	DP=zeros(size(xyi));
	for i=1:size(xyi,1)
		xs = xyi(i,1);
		ys = xyi(i,2);
		if hypot(xs-xyo(:,1),ys-xyo(:,2))<eps
			DP(i,1)=530;
			DP(i,2)=0;
			break
			end
		low=1;
		high=RealHigh;
		uv = Crossing(xy(:,1), xy(:,2), low, high, xs, ys, xyo(:,1), xyo(:,2), 1);
		if 0 < uv(1) && uv(1) < 1 && uv(2)>=0
			Dir=-1;
		else
			Dir=1;
			end
		mid=find(lam==520);
		while low + 1 < high
			uv = Crossing(xy(:,1), xy(:,2), low, mid, xs, ys, xyo(:,1), xyo(:,2), Dir);
			if uv(1) < 1 && uv(2)>0
				high = mid;
			else
				uv = Crossing(xy(:,1), xy(:,2), mid, high, xs, ys, xyo(:,1), xyo(:,2), Dir);
				low = mid;
				end;
			mid=round(mean([low high]));
			if VISUALIZE
				plot( ...
					  xy(:,1),xy(:,2),'.' ...
					, xy([low high],1),xy([low high],2),'o-' ...
					, xyo(:,1),xyo(:,2),'o' ...
					, xs,ys,'x' ...
					, [xy(low,1) xy(low,1)+(xy(high,1)-xy(low,1))*uv(1)], [xy(low,2) xy(low,2)+(xy(high,2)-xy(low,2))*uv(1)], ':k' ...
					, [xyo(:,1) xyo(:,1)+Dir*uv(2)*(xs-xyo(:,1))], [xyo(:,2) xyo(:,2)+Dir*uv(2)*(ys-xyo(:,2))], '--k' ...
					);
				title(sprintf('u=%.2f, v=%.2f', uv))

				pause
				end
			end
		DP(i,1)=Dir*(lam(1) +diff(lam([1 2]))*((low-1)+uv(1)));
		DP(i,2)=1/uv(2);
		end
	
function uv=Crossing(x, y, low ,high, xs, ys, xo, yo, Dir)
	uv=[x(low)-x(high) Dir*(xs-xo); y(low)-y(high) Dir*(ys-yo)] \ [x(low)-xo; y(low)-yo];
