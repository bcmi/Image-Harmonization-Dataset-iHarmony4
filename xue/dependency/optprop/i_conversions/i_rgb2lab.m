function lab=i_rgb2lab(rgb,rgbtype,IllObs, varargin)
%I_RGB2LAB Convert from RGB to Lab.
%   LAB=I_RGB2LAB(RGB,RGBTYPE,CWF) with size(RGB)=[M 3] returns
%   matrix LAB with same size.
%
%   RGBTYPE is one of the predefined RGB types or a conforming struct, see RGBS.
%   If empty, the default RGBTYPE, OPTGETPREF('WorkingRGB'), is used.
%
%   CWF is a color weighting function specification. It can be a
%   string, e.g. 'D50/2', or a struct, see MAKECWF. If empty, the
%   the default cwf, OPTGETPREF('cwf') is used.
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
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use RGB2LAB instead.
%
%   Example:
%      Convert the corners of the RGB cube to Lab
%         rgb=cat(3,[0 1 1 0 0 0 1 1],[0 0 1 1 1 0 0 1],[0 0 0 0 1 1 1 1]);
%         rgb=reshape(rgb,[],3);
%         lab=i_rgb2lab(rgb,'srgb', 'D65/10');
%         dsp=i_rgb2disp(rgb,'srgb');
%         % Show the result
%         subplot(121);ballplot(rgb,dsp,.1,2);camlight;
%         subplot(122);ballplot(lab(:,[2 3 1]),dsp,18,2);camlight;
%
%   See also: RGB2LAB, I_LAB2RGB, MAKECWF, RGBS, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_rgb2lab.m 24 2007-01-28 23:20:35Z jerkerw $

	lab=i_xyz2lab(i_rgb2xyz(rgb, rgbtype, IllObs, varargin{:}), IllObs);
