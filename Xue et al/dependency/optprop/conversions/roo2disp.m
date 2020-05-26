function varargout=roo2disp(varargin)
%ROO2DISP Convert from spectra to DisplayRGB.
%   RGB=ROO2DISP(ROO,WL) with size(ROO)=[M N ... P W] returns
%   matrix RGB with size [M N ... P 3].
%
%   [R,G,B]=ROO2DISP(ROO,WL) with size(ROO)=[M N ... P W] returns
%   matrices R, G and B, each with size [M N ... P].
%
%   ROO holds M*N*...*P spectral readings with W spectral bands and WL,
%   size [1 W], holds the wavelengths. If WL is omitted or empty, the
%   default wavelength range, DWL, is used for WL.
%
%   The RGB type used is taken from OPTGETPREF('DisplayRGB');
%
%   Example:
%      Display the ColorChecker chart.
%
%         image(roo2disp(colorchecker));
%         axis image
%
%   See also: RGB2ROO, OPTGETPREF, I_ROO2RGB

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: roo2disp.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([1 0 1 0],5,@i_roo2disp,varargin{:});
	error(err);
