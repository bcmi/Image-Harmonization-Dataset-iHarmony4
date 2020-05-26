function varargout=rgb2rgb(varargin)
%RGB2RGB Convert from one RGB space into another.
%   ARGB=RGB2RGB(RGB,SRCTYPE, DSTTYPE) with size(RGB)=[M N ... P 3]
%   returns matrix ARGB with same size.
%
%   ARGB=RGB2RGB(R,G,B,SRCTYPE,DSTTYPE) with size of R,G,B = [M N ... P]
%   returns matrix ARGB with size [M N ... P 3].
%
%   [AR,AG,AB]=RGB2RGB(RGB,SRCTYPE,DSTTYPE) size(RGB)=[M N ... P 3] returns
%   matrices AR, AG and AB, each with size [M N ... P].
%
%   [AR,AG,AB]=RGB2RGB(R,G,B,SRCTYPE,DSTTYPE) size(R,G,B)=[M N ... P] returns
%   returns equally sized matrices AR, AG and AB.
%
%   SRCTYPE asn DSTTYPE are one of the predefined RGB types or a conforming
%   struct, see RGBS. If omitted or empty, the default RGBTYPE,
%   OPTGETPREF('WorkingRGB'), is used.
%
%   [...]=RGB2RGB(..., 'SRCGAMMA', G) applies G instead of the default gamma
%   stipulated for the SRCTYPE.
%
%   [...]=RGB2RGB(..., 'DSTGAMMA', G) applies 1/G instead of the default gamma
%   stipulated for the DSTTYPE.
%
%   [...]=RGB2RGB(..., 'CAT', C) with string C, defines which chromatic
%   adaptation transform to use. C can be one of 'none', 'xyz', 'bradford'
%   or 'vonkries'. Default = 'bradford'.
%
%   [...]=RGB2RGB(..., 'CLASS', C) with M={'double'|'single'|'uint16'|'uint8'} converts
%   the output to CLASS C, instead of the default, which is the same as the input.
%
%   [...]=RGB2RGB(..., 'CLIP', C) with C={'on'|'off'} enables or disables
%   limiting between [0,1]. Default 'on'
%
%   Remark:
%   Remember that when converting from a wider RGB space into a smaller,
%   clipping may occur, so that e.g.
%      rgb2rgb(rgb2rgb(rgb,'srgb','adobe'),'adobe','srgb') ~= rgb
%
%   Example:
%      Visualize where in RGB-space data get changed the most when
%      converting from sRGB to Adobe RGB
%
%         r=colorchecker;
%         srgb=roo2rgb(r,'srgb');
%         argb=rgb2rgb(srgb,'srgb','adobe');
%         % DE works with any cartesian system ...
%         dr=de(srgb,argb);
%         ballplot(srgb,srgb,dr,3);
%         camlight;
%         lighting phong
%
%   See also: RGB2RGB, MAKECWF, RGBS, OPTGETPREF, I_RGB2RGB

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: rgb2rgb.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([3 2 0 6],[4 4],@i_rgb2rgb,varargin{:});
	error(err);

