function varargout=roo2xyz(varargin)
%ROO2XYZ Convert from spectra to XYZ.
%   XYZ=ROO2XYZ(ROO,CWF,WL) with size(ROO)=[M N ... P W] returns
%   matrix XYZ with same size.
%
%   [X,Y,Z]=ROO2XYZ(ROO,CWF,WL) with size(ROO)=[M N ... P W] returns
%   matrices X, Y and Z, each with size [M N ... P].
%
%   ROO holds M*N*...*P spectral readings with W spectral bands and WL,
%   size [1 W], holds the wavelengths. If WL is omitted or empty, the
%   default wave- length range, DWL, is used for WL.
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%   ...=ROO2XYZ(..., 'ASTM', SELSTR, with SELSTR being one of
%   'off', 'only' or 'first', specifies whether ASTM colormatching
%   functions shall be used or not. If 'off', the cmf are always calculated
%   from scratch, based on specified illuminant and observer. If 'only',
%   only ASTM tables are used, and if 'first', ASTM is used if there
%   exists a suitable table.
%
%   ...=ROO2XYZ(..., 'SpectrumType', TYPE), where TYPE is one of
%   'compensated' or 'uncompensated', specifies whether the input
%   spectrum/spectra are compensated for spectral bandwidth or not. If
%   'uncompensated', ASTM E308 Table 6 values are used for ASTM cwf:s, and
%   for non-ASTM, the Stearns-Stearns algorithm.
%
%   Example:
%      xyz=roo2xyz(rosch);
%      viewgamut(xyz,'xyz');
%
%   See also ROO2LAB, ROO2XY, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: roo2xyz.m 23 2007-01-28 22:55:34Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([1 0 2 2],[1 5],@i_roo2xyz,varargin{:});
	error(err);
