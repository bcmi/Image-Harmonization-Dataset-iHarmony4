function varargout=roo2rgb(varargin)
%ROO2RGB Convert from spectra to RGB.
%   RGB=ROO2RGB(ROO,RGBTYPE,WL) with size(ROO)=[M N ... P W] returns
%   matrix RGB with size [M N ... P 3].
%
%   [R,G,B]=ROO2RGB(ROO,RGBTYPE,WL) with size(ROO)=[M N ... P W] returns
%   matrices R, G and B, each with size [M N ... P].
%
%   ROO holds M*N*...*P spectral readings with W spectral bands and WL,
%   size [1 W], holds the wavelengths. If WL is omitted or empty, the
%   default wavelength range, DWL, is used for WL.
%
%   RGBTYPE is one of the predefined RGB types or a conforming struct, see RGBS.
%   If omitted or empty, the default RGBTYPE, OPTGETPREF('WorkingRGB'), is used.
%
%   [...]=ROO2RGB(..., 'GAMMA', G) applies 1/G instead of the default gamma
%   specified for the RGBTYPE.
%
%   [...]=ROO2RGB(...,'CAT',C) with string C, defines which chromatic
%   adaptation transform to use. C can be one of 'none', 'xyz', 'bradford'
%   or 'vonkries'. Default = 'bradford'.
%
%   [...]=ROO2RGB(..., 'CLIP', C) with C={'on'|'off'} enables or disables
%   output limiting between [0,1]. Default 'on'.
%
%   Example:
%      Show where in RGB space ColorChecker patches are located.
%
%         rgb=roo2rgb(colorchecker, 'srgb');
%         ballplot(rgb(:,:,1),rgb(:,:,2),rgb(:,:,3), rgb,.05,2);
%         camlight;
%         lighting phong
%
%   See also: MAKECWF, RGBS, OPTGETPREF, I_ROO2RGB

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: roo2rgb.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([1 0 2 4],[4 5],@i_roo2rgb,varargin{:});
	error(err);

