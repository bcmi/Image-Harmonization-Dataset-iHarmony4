function varargout=roo2brightness(varargin)
%ROO2BRIGHTNESS Convert spectrum to ISO Brightness.
%   BRIGHTNESS=ROO2BRIGHTNESS(ROO,WL) with size(ROO)=[M N ... P W] returns
%   matrix BRIGHTNESS with size [M N ... P].
%
%   ROO holds M*N*...*P spectral readings with W spectral bands and WL,
%   size [1 W], holds the wavelengths. If WL is omitted or empty, the
%   default wavelength range, DWL, is used for WL.
%
%   Example:
%   Calculate Brightness for the ColorChecker patches:
%
%      B=roo2brightness(colorchecker)
%
%   See also: DWL, I_ROO2BRIGHTNESS

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: roo2brightness.m 24 2007-01-28 23:20:35Z jerkerw $


	[err,varargout{1:max(1,nargout)}]=optproc([1 0 1 0],5,@i_roo2brightness,varargin{:});
	error(err);
