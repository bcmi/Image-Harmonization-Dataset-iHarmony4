function varargout=roo2lab(varargin)
%ROO2LAB Convert from spectra to LAB.
%   LAB=ROO2LAB(ROO,CWF,WL) with size(ROO)=[M N ... P W] returns
%   matrix LAB with size [M N ... P 3].
%
%   [L,A,B]=ROO2LAB(ROO,CWF,WL) with size(ROO)=[M N ... P W] returns
%   matrices L, A and B, each with size [M N ... P].
%
%   ROO holds M*N*...*P spectral readings with W spectral bands and WL,
%   size [1 W], holds the wavelengths. If WL is omitted or empty, the
%   default wavelength range, DWL, is used for WL.
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%   Example:
%      lab=roo2lab(rosch);
%      viewlab(lab);
%
%   See also: LAB2ROO, MAKECWF, DWL, OPTGETPREF, I_ROO2LAB

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: roo2lab.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([1 0 2 2],[1 5],@i_roo2lab,varargin{:});
	error(err);

