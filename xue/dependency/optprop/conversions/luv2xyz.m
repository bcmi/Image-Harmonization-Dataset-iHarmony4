function varargout=luv2xyz(varargin)
%LUV2XYZ Convert from Luv to XYZ.
%   XYZ=LUV2XYZ(LUV,CWF) with size(LUV)=[M N ... P 3] returns
%   matrix XYZ with same size.
%
%   XYZ=LUV2XYZ(L,U,V,CWF) with size(L,U,V)=[M N ... P] returns
%   matrix XYZ with size [M N ... P 3].
%
%   [X,Y,Z]=LUV2XYZ(LUV,CWF) with size(LUV)=[M N ... P 3] returns
%   matrices X, Y and Z, each with size [M N ... P].
%
%   [X,Y,Z]=LUV2XYZ(L,U,V,CWF) with size(L,U,V)=[M N ... P]
%   returns equally sized matrices X, Y and Z.
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%   Example:
%      luv2xyz([30 40 50],'D65/2')
%
%   See also: XYZ2LUV, MAKECWF, OPTGETPREF, I_LUV2XYZ

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: luv2xyz.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([3 0 1 0],1,@i_luv2xyz,varargin{:});
	error(err);

