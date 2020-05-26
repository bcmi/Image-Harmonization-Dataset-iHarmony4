function xtyt=i_dp2xy(dp, IllObs)
%I_DP2XY Calculate chromaticity from dominating wavelength and spectral purity.
%   XY=I_DP2XY(DP,CWF) with size(DP)=[M 2] returns
%   matrix XY with same size.
%
%   CWF is a color weighting function specification. It can be a
%   string, e.g. 'D50/2', or a struct, see MAKECWF. If empty, the
%   the default cwf, OPTGETPREF('cwf') is used.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use DP2XY instead.
%
%   Example:
%      Show the locus of xy with the spectral purity = 0.5 in the
%      chromaticity plane
%
%          lam=linspace(380,720,20)';
%          xy=i_dp2xy([lam .5*ones(size(lam))],'D50/2');
%          plot(xy(:,1),xy(:,2), 'LineWidth', 2)
%          hold on
%          helmholtz
%          hold off
%          axis equal
%
%   See also: DP2XY, MAKECMF, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_dp2xy.m 23 2007-01-28 22:55:34Z jerkerw $

	n=size(dp,1);
	[w,Lambda]=observer(cwf2obs(IllObs));
	xpyp=i_xyz2xy(w);
	xoyo=i_xyz2xy(wpt(IllObs));
	Dir=dp(:,1)<0;
	dp(Dir,1)=-dp(Dir,1);
	xptypt=interp1(Lambda,xpyp,dp(:,1));
	xtyt=repmat(xoyo,n,1)+(xptypt-repmat(xoyo,n,1)).*repmat(dp(:,2),1,2);
