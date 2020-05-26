function varargout=xyz2luv(varargin)
%XYZ2LUV Convert from XYZ to LUV.
%   LUV=XYZ2LUV(XYZ,CWF) with size(XYZ)=[M N ... P 3] returns
%   matrix LUV with same size.
%
%   LUV=XYZ2LUV(X,Y,Z,CWF) with size(X,Y,Z)=[M N ... P] returns
%   matrix LUV with size [M N ... P 3].
%
%   [L,U,V]=XYZ2LUV(XYZ,CWF) with size(XYZ)=[M N ... P 3] returns
%   matrices L, U and V, each with size [M N ... P].
%
%   [L,U,V]=XYZ2LUV(X,Y,Z,CWF) with size(X,Y,Z)=[M N ... P]
%   returns equally sized matrices L, U and V.
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%   Example:
%      xyz2luv([30 40 50], 'D50/2')
%
%   See also: LUV2XYZ, MAKECWF, OPTGETPREF, I_XYZ2LUV

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: xyz2luv.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([3 0 1 0],1,@i_xyz2luv,varargin{:});
	error(err);
