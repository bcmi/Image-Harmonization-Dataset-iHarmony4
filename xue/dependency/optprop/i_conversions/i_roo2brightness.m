function B=i_roo2brightness(Roo,wl)
%I_ROO2BRIGHTNESS Convert spectrum to ISO Brightness.
%   BRIGHTNESS=I_ROO2BRIGHTNESS(ROO,WL) with size(ROO)=[M W] returns
%   matrix BRIGHTNESS with size [M N ... P].
%
%   ROO holds M spectral readings with W spectral bands and WL, size [1 W],
%   holds the wavelengths. 
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use ROO2BRIGHTNESS instead.
%
%   Example:
%   Calculate Brightness for the ColorChecker patches:
%
%      wl=400:10:700;
%      cc=reshape(colorchecker(wl),[],length(wl));
%      B=reshape(i_roo2brightness(cc,wl),4,6)
%
%   See also: ROO2BRIGHTNESS

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_roo2brightness.m 46 2007-03-28 08:52:17Z jerkerw $

	%      400   410   420   430    440    450    460    470    480   490   500   510
	w31=[0.213 1.430 3.885 7.364 12.295 17.609 21.345 18.933 11.334 4.333 1.195 0.064];
	ws=warning('off','MATLAB:interp1:NaNinY');
	iRoo=interp1(wl,Roo',400:10:510, 'linear',0);
	warning(ws);
	if ~isvector(iRoo)
		iRoo=iRoo';
		end
	B=iRoo * w31'/100;
