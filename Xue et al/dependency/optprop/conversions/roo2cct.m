function varargout=roo2cct(varargin)
%ROO2CCT Calculate correlated color temperature.
%   CCT=ROO2CCT(ROO,OBS,WL) with size(ROO)=[M N ... P W] returns
%   matrix CCT with same size.
%
%   ROO holds M*N*...*P spectral readings with W spectral bands and WL,
%   size [1 W], holds the wavelengths. If WL is omitted or empty, the
%   default wavelength range, DWL, is used for WL.
%
%   OBS is an char array observer specification, e.g '2' or '10'. It can
%   also be a char array color weighting function specification, e.g.
%   'D50/2'. In that case the illuminant part is ignored. If OBS is omitted
%   or empty, the observer part in DCWF is used.
%
%   Remark
%   Since the algorithm for calculating is based on XYZ, the CCT will
%   change with the observer. I haven't yet figured out if this is
%   reasonable or not...
%
%	Example:
%      flat=100*ones(1,length(dwl));
%      roo2cct(flat,'2')            
%      roo2cct(flat,'10')           
%      roo2cct(blackbody(5000),'2')
%      roo2cct(dill(5000),'2')
%
%   See also: DWL,BLACKBODY, DILL, OPTGETPREF, I_ROO2CCT

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: roo2cct.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([1 0 2 0],[3 5],@i_roo2cct,varargin{:});
	error(err);

