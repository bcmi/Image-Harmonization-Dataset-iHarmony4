function varargout=rgb2xyz(varargin)
%RGB2XYZ Convert from RGB to XYZ.
%   XYZ=RGB2XYZ(RGB,RGBTYPE,CWF) with size(RGB)=[M N ... P 3] returns
%   matrix XYZ with same size.
%
%   XYZ=RGB2XYZ(R,G,B,RGBTYPE,CWF) with size(R,G,B)=[M N ... P] returns
%   matrix XYZ with size [M N ... P 3].
%
%   [X,Y,Z]=RGB2XYZ(RGB,RGBTYPE,CWF) with size(RGB)=[M N ... P 3] returns
%   matrices X, Y and Z, each with size [M N ... P].
%
%   [X,Y,Z]=RGB2XYZ(R,G,B,RGBTYPE,CWF) with size(R,G,B)=[M N ... P]
%   returns equally sized matrices X, Y and Z.
%
%   RGBTYPE is one of the predefined RGB types or a conforming struct, see RGBS.
%   If omitted or empty, the default RGBTYPE, OPTGETPREF('WorkingRGB'), is used.
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%   [...]=RGB2XYZ(..., 'GAMMA', G) applies 1/G instead of the default gamma
%   specified for the RGBTYPE.
%
%   [...]=RGB2XYZ(..., 'CAT', C) with string C, defines which chromatic
%   adaptation transform to use. C can be one of 'none', 'xyz', 'bradford'
%   or 'vonkries'. Default = 'bradford'.
%
%   [...]=RGB2XYZ(..., 'CLIP', C) with C={'on'|'off'} enables or disables
%   RGB input limiting between [0,1]. Default 'on'
%
%   Example:
%      Convert the corners of the RGB cube to XYZ
%         rgb=cat(3,[0 1 1 0 0 0 1 1],[0 0 1 1 1 0 0 1],[0 0 0 0 1 1 1 1]);
%         xyz=rgb2xyz(rgb,'srgb', 'D65/10');
%         % Show the result
%         subplot(121);ballplot(rgb,rgb,.1,2);camlight;
%         subplot(122);ballplot(xyz,rgb,10,2);camlight;
%
%   See also: XYZ2RGB, MAKECWF, RGBS, OPTGETPREF, I_RGB2XYZ

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: rgb2xyz.m 24 2007-01-28 23:20:35Z jerkerw $


	[err,varargout{1:max(1,nargout)}]=optproc([3 0 2 4],[4 1],@i_rgb2xyz,varargin{:});
	error(err);

