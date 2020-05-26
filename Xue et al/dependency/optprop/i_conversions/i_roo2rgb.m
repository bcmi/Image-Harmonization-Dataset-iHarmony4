function rgb=i_roo2rgb(Roo,rgbtype,wl,varargin)
%I_ROO2RGB Convert from spectra to RGB.
%   RGB=I_ROO2RGB(ROO,RGBTYPE,WL) with size(ROO)=[M W] returns matrix RGB
%   with size [M 3].
%
%   ROO holds M spectral readings with W spectral bands and WL, size [1 W],
%   holds the wavelengths.
%
%   RGBTYPE is one of the predefined RGB types or a conforming struct, see RGBS.
%   If empty, the default RGBTYPE, OPTGETPREF('WorkingRGB'), is used.
%
%   [...]=I_ROO2RGB(..., 'GAMMA', G) applies 1/G instead of the default gamma
%   specified for the RGBTYPE.
%
%   [...]=I_ROO2RGB(...,'CAT',C) with string C, defines which chromatic
%   adaptation transform to use. C can be one of 'none', 'xyz', 'bradford'
%   or 'vonkries'. Default = 'bradford'.
%
%   [...]=I_ROO2RGB(..., 'CLIP', C) with C={'on'|'off'} enables or disables
%   output limiting between [0,1]. Default 'on'.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use ROO2RGB instead.
%
%   Example:
%      Show where in RGB space ColorChecker patches are located.
%
%         rgb=i_roo2rgb(reshape(colorchecker(dwl),[],length(dwl)), 'srgb',dwl);
%         ballplot(rgb(:,1),rgb(:,2),rgb(:,3), rgb,.05,2);
%         camlight;
%         lighting phong
%
%   See also: ROO2RGB, RGBS, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_roo2rgb.m 24 2007-01-28 23:20:35Z jerkerw $

	type=rgbs(rgbtype);
	xyz=i_roo2xyz(Roo, type.IllObs, wl);
	rgb=i_xyz2rgb(xyz, type.IllObs, rgbtype, varargin{:});
