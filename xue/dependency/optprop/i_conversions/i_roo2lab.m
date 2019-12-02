function lab=i_roo2lab(Roo, IllObs, wl,varargin)
%I_ROO2LAB Convert from spectra to LAB.
%   LAB=I_ROO2LAB(ROO,CWF,WL) with size(ROO)=[M W] returns matrix LAB with
%   size [M 3].
%
%   ROO holds M spectral readings with W spectral bands and WL, size [1 W],
%   holds the wavelengths.
%
%   CWF is a color weighting function specification. It can be a
%   string, e.g. 'D50/2', or a struct, see MAKECWF. If empty, the
%   the default cwf, OPTGETPREF('cwf') is used.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use ROO2LAB instead.
%
%   Example:
%      wl=400:10:700;
%      roo=rosch(length(wl));
%      sz=size(roo);
%      roo=reshape(roo,[],length(wl));
%      lab=i_roo2lab(roo,'D65/10',wl);
%      lab=reshape(lab,[sz([1 2]) 3]);
%      viewlab(lab);
%
%   See also: ROO2LAB, I_LAB2ROO, MAKECWF, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_roo2lab.m 24 2007-01-28 23:20:35Z jerkerw $

	Default=struct( ...
		  'ASTM', optgetpref('ASTM') ...
		  ,'SpectrumType', optgetpref('SpectrumType') ...
		  );
	par=args2struct(Default,varargin);
	par.ASTM=partialmatch(par.ASTM, {'off', 'first', 'only'});
	par.SpectrumType=partialmatch(par.SpectrumType, {'compensated', 'uncompensated'});

	lab=i_xyz2lab(i_roo2xyz(Roo, IllObs, wl, 'ASTM', par.ASTM, 'SpectrumType', par.SpectrumType), IllObs);
