function varargout=xy2dp(varargin)
%XY2DP Calculate dominating wavelength and exitation purity.
%   DP=XY2DP(XY,CWF) with size(XY)=[M N ... P 2] returns
%   matrix DP with same size.
%
%   DP=XY2DP(X,Y,CWF) with size(X,Y)=[M N ... P] returns
%   matrix DP with size [M N ... P 2].
%
%   [D,P]=XY2DP(XY,CWF) with size(XY)=[M N ... P 2] returns
%   matrices D and P, each with size [M N ... P].
%
%   [D,P]=XY2DP(X,Y,CWF) with size(X,Y)=[M N ... P]
%   returns equally sized matrices D and P.
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%   Example:
%      Get dominating wavelength for the D65/10 whitepoint and excitation
%      purity under C/2:
%
%         xy2dp(xyz2xy(wpt('D65/10')),'C/2')
%
%   See also: DP2XY, MAKECWF, OPTGETPREF, I_XY2DP

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: xy2dp.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([2 0 1 0],1,@i_xy2dp,varargin{:});
	error(err);
