function varargout=xyz2wtj(varargin)
%XYZ2WTJ Convert from XYZ to CIE Whiteness, T(Red Tint) and J (Yellowness).
%   WTJ=XYZ2WTJ(XYZ,CWF) with size(XYZ)=[M N ... P 3] returns
%   matrix WTJ with same size.
%
%   WTJ=XYZ2WTJ(X,Y,Z,CWF) with size(X,Y,Z)=[M N ... P] returns matrix WTJ
%   with size [M N ... P 3].
%
%   [W,T,J]=XYZ2WTJ(XYZ,CWF) with size(XYZ)=[M N ... P 3] returns matrices
%   W, T and J, each with size [M N ... P].
%
%   [W,T,J]=XYZ2WTJ(X,Y,Z,CWF) with size(X,Y,Z)=[M N ... P] returns equally
%   sized matrices W, T and J.
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%   Example:
%      wtj=xyz2wtj([84 89 93],'D65/10')
%
%   See also: WTJ2XYZ, MAKECWF, OPTGETPREF, I_XYZ2WTJ

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: xyz2wtj.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([3 0 1 0],1,@i_xyz2wtj,varargin{:});
	error(err);

