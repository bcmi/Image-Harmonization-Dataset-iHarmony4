function varargout=rgb2lab(varargin)
%RGB2LAB Convert from RGB to Lab.
%   LAB=RGB2LAB(RGB,RGBTYPE,CWF) with size(RGB)=[M N ... P 3] returns
%   matrix LAB with same size.
%
%   LAB=RGB2LAB(R,G,B,RGBTYPE,CWF) with size(R,G,B)=[M N ... P] returns
%   matrix LAB with size [M N ... P 3].
%
%   [L,A,B]=RGB2LAB(RGB,RGBTYPE,CWF) with size(RGB)=[M N ... P 3] returns
%   matrices L, A and B, each with size [M N ... P].
%
%   [L,A,B]=RGB2LAB(R,G,B,RGBTYPE,CWF) with size(R,G,B)=[M N ... P]
%   returns equally sized matrices L, A and B.
%
%   RGBTYPE is one of the predefined RGB types or a conforming struct, see RGBS.
%   If omitted or empty, the default RGBTYPE, OPTGETPREF('WorkingRGB'), is assumed.
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%   [...]=RGB2XYZ(..., 'GAMMA', G) applies 1/G instead of the default gamma
%   specified for the RGBTYPE.
%
%   [...]=XYZ2XYZ(..., 'CAT', C) with string C, defines which chromatic
%   adaptation transform to use. C can be one of 'none', 'xyz', 'bradford'
%   or 'vonkries'. Default = 'bradford'.
%
%   [...]=RGB2XYZ(..., 'CLIP', C) with C={'on'|'off'} enables or disables
%   RGB input limiting between [0,1]. Default 'on'
%
%   Example:
%      Convert the corners of the RGB cube to Lab
%         rgb=cat(3,[0 1 1 0 0 0 1 1],[0 0 1 1 1 0 0 1],[0 0 0 0 1 1 1 1]);
%         lab=rgb2lab(rgb,'srgb', 'D65/10');
%         dsp=rgb2disp(rgb,'srgb');
%         % Show the result
%         subplot(121);ballplot(rgb,dsp,.1,2);camlight;
%         subplot(122);ballplot(lab(:,:,[2 3 1]),dsp,18,2);camlight;
%
%   See also: LAB2RGB, MAKECWF, RGBS, OPTGETPREF, I_RGB2LAB

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: rgb2lab.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([3 0 2 4],[4 1],@i_rgb2lab,varargin{:});
	error(err);

