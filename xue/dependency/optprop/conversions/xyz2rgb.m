function varargout=xyz2rgb(varargin)
%XYZ2RGB Convert from XYZ to RGB.
%   RGB=XYZ2RGB(XYZ,CWF,RGBTYPE) with size(XYZ)=[M N ... P 3] returns
%   matrix RGB with same size.
%
%   RGB=XYZ2RGB(X,Y,Z,CWF,RGBTYPE) with size(X,Y,Z)=[M N ... P] returns
%   matrix RGB with size [M N ... P 3].
%
%   [R,G,B]=XYZ2RGB(XYZ,CWF,RGBTYPE) with size(XYZ)=[M N ... P 3] returns
%   matrices R, G and B, each with size [M N ... P].
%
%   [R,G,B]=XYZ2RGB(X,Y,Z,CWF,RGBTYPE) with size(X,Y,Z)=[M N ... P]
%   returns equally sized matrices R, G and B.
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%   RGBTYPE is one of the predefined RGB types or a conforming struct, see RGBS.
%   If omitted or empty, the default RGBTYPE, OPTGETPREF('WorkingRGB'), is used.
%
%   [...]=XYZ2RGB(..., 'GAMMA', G) applies 1/G instead of the default gamma
%   specified for the RGBTYPE.
%
%   [...]=XYZ2RGB(...,'CAT',C) with string C, defines which chromatic
%   adaptation transform to use. C can be one of 'none', 'xyz', 'bradford'
%   or 'vonkries'. Default = 'bradford'.
%
%   [...]=XYZ2RGB(..., 'CLIP', C) with C={'on'|'off'} enables or disables
%   output limiting between [0,1]. Default 'on'
%
%   Example:
%      z=xyz2rgb([30 40 50],'D50/2','srgb')
%
%   See also: RGB2XYZ, MAKECWF, RGBS, OPTGETPREF, I_XYZ2RGB

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: xyz2rgb.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([3 0 2 3],[1 4],@i_xyz2rgb,varargin{:});
	error(err);
