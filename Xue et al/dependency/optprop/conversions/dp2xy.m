function varargout=dp2xy(varargin)
%DP2XY Calculate chromaticity from dominating wavelength and spectral purity.
%   XY=DP2XY(DP,CWF) with size(DP)=[M N ... P 2] returns
%   matrix XY with same size.
%
%   XY=DP2XY(D,P,CWF) with size(D,P)=[M N ... P] returns
%   matrix XY with size [M N ... P 2].
%
%   [X,Y]=DP2XY(DP,CWF) with size(DP)=[M N ... P 2] returns
%   matrices X and Y, each with size [M N ... P].
%
%   [X,Y]=DP2XY(D,P,CWF) with size(D,P)=[M N ... P]
%   returns equally sized matrices X and Y.
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%   Example:
%      Show the locus of xy with the spectral purity = 0.5 in the
%      chromaticity plane
%
%          lam=linspace(380,720,20);
%          [x,y]=dp2xy(lam,.5*ones(size(lam)));
%          plot(x,y, 'LineWidth', 2)
%          hold on
%          helmholtz
%          hold off
%          axis equal
%
%   See also: I_DP2XY, XY2DP, MAKECMF, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: dp2xy.m 23 2007-01-28 22:55:34Z jerkerw $

	varargout=cell(1,max(1,nargout));
	[err,varargout{:}]=optproc([2 0 1 0],1,@i_dp2xy,varargin{:});
	error(err);

