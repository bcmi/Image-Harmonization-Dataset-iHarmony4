function cct=i_roo2cct(Roo, obs, wl)
%I_ROO2CCT Calculate correlated color temperature.
%   CCT=I_ROO2CCT(ROO,OBS,WL) with size(ROO)=[M W] returns
%   matrix CCT with same size.
%
%   ROO holds M spectral readings with W spectral bands and WL, size [1 W],
%   holds the wavelengths. If WL is empty, the default wavelength range,
%   DWL, is used for WL.
%
%   OBS is an char array observer specification, e.g '2' or '10'. It can
%   also be a char array color weighting function specification, e.g.
%   'D50/2'. In that case the illuminant part is ignored. If OBS is omitted
%   or empty, the observer part in OPTGETPREF('cwf') is used.
%
%   Remark:
%      Since the algorithm for calculating is based on XYZ, the CCT will
%      change with the observer. I haven't yet figured out if this is
%      reasonable or not...
%
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use ROO2CCT instead.
%
%	Example:
%      flat=100*ones(1,length(dwl));
%      i_roo2cct(flat,'2',dwl)
%      i_roo2cct(flat,'10',dwl)
%      i_roo2cct(blackbody(5000),'2',dwl)
%      i_roo2cct(dill(5000),'2',dwl)
%
%   See also: ROO2CCT, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_roo2cct.m 24 2007-01-28 23:20:35Z jerkerw $

	illobs=makecwf(['E/' obs]);
	xyz=i_roo2xyz(Roo,illobs,wl);
	cct=i_xy2cct(xyz2xy(xyz));
