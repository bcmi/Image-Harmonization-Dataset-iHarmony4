function varargout=lab2rgb(varargin)
%LAB2RGB Convert from Lab to RGB.
%   RGB=LAB2RGB(LAB,CWF,RGBTYPE) with size(LAB)=[M N ... P 3] returns
%   matrix RGB with same size.
%
%   RGB=LAB2RGB(L,A,B,CWF,RGBTYPE) with size(L,A,B)=[M N ... P] returns
%   matrix RGB with size [M N ... P 3].
%
%   [R,G,B]=LAB2RGB(LAB,CWF,RGBTYPE) with size(LAB)=[M N ... P 3] returns
%   matrices R, G and B, each with size [M N ... P].
%
%   [R,G,B]=LAB2RGB(L,A,B,CWF,RGBTYPE) with size(L,A,B)=[M N ... P]
%   returns equally sized matrices R, G and B.
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%   RGBTYPE is one of the predefined RGB types or a conforming struct, see RGBS.
%   If omitted or empty, the default RGBTYPE, OPTGETPREF('WorkingRGB'), is used.
%
%   [...]=LAB2RGB(..., 'GAMMA', G) applies 1/G instead of the default gamma
%   specified for the RGBTYPE.
%
%   [...]=LAB2RGB(..., 'CAT', C) with string C, defines which chromatic
%   adaptation transform to use. C can be one of 'none', 'xyz', 'bradford'
%   or 'vonkries'. Default = 'bradford'.
%
%   [...]=LAB2RGB(..., 'CLIP', C) with C={'on'|'off'} enables or disables
%   RGB input limiting between [0,1]. Default 'on'
%
%   Example:
%      Convert a scaled down rosch space into sRGB
%
%         lab=.8*roo2lab(rosch);
%         rgb=lab2rgb(lab,'D65/10','srgb');
%         % Show the result
%         subplot(121);viewlab(lab,rgb);
%         subplot(122);viewgamut(rgb,rgb);axis([0 1 0 1 0 1]);
%
%   See also: RGB2LAB, MAKECWF, RGBS, OPTGETPREF, I_LAB2RGB

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: lab2rgb.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([3 0 2 4],[1 4],@i_lab2rgb,varargin{:});
	error(err);
