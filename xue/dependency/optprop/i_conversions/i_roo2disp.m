function rgb=i_roo2disp(Roo,wl,varargin)
%I_ROO2DISP Convert from spectra to DisplayRGB.
%   RGB=I_ROO2RGB(ROO,WL) with size(ROO)=[M W] returns matrix RGB with same
%   size.
%
%   ROO holds M spectral readings with W spectral bands and WL, size [1 W],
%   holds the wavelengths. If WL is omitted or empty, the default wave-
%   length range, DWL, is used for WL.
%
%   Example:
%      Show where in RGB space ColorChecker patches are located.
%
%         image(roo2disp(colorchecker));
%         axis image
%
%   See also: RGB2ROO, OPTGETPREF, I_ROO2RGB

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_roo2disp.m 24 2007-01-28 23:20:35Z jerkerw $

	% Since we are using the same illuminant/observer pair in the
    % roo2xyz conversion as in the subsequent xyz2rgb, the xyz2xyz within
    % xyz2rgb is in effect a null operation, as it should be since we
	% are dealing with spectra.

	type=rgbs(optgetpref('DisplayRGB'));
	xyz=roo2xyz(Roo, type.IllObs, wl);
	rgb=xyz2rgb(xyz, type.IllObs, type, varargin{:});
