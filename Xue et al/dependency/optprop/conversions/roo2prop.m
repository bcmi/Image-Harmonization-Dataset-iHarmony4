function varargout=roo2prop(varargin)
%ROO2PROP Convert from spectra to various optical properties.
%   ROO2PROP converts spectral values to specified optical values.
%
%   Z=ROO2XYZ(ROO, PROPS, CWF, WL) with size(ROO)=[M N ... O W],
%   char array PROPS size [1 P] and row vector size [1 W], returns matrix Z
%   with size [M N ... O P].  
%
%   [A,B,C, ...]=ROO2XYZ(ROO,PROPS,ILLOBS,WL) returns A,B,C,... each
%   with size [M N ... O].
%
%   PROPS can be any one of 'LabWTJXYZxyB' and/or any of 'Rx','Ry','Rz'.
%   These specifiers are case sensitive. PROPLEN is the number of speci-
%   fiers in PROPS, where 'Rx', 'Ry' and 'Rz' counts as one specifier.
%   
%      L  CIE L*          W  CIE Whiteness
%      a  CIE a*          T  CIE Tint
%      b  CIE b*          J  Yellowness
%      X  CIE X           Rx
%      Y  CIE Y           Ry
%      Z  CIE Z           Rz
%      B  ISO Brightness 
%
%   If WL is not specified, the last dimension of the spectra, W, must be
%   the same as the default wavelength range, DWL.
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%
% Example:
%      Get the Lab and CIE Whiteness into a [1 4] row vector
%         z=roo2prop(100*ones(1,length(dwl)),'LabW','D65/10')
%
%   See also: ROO2XYZ, ROO2LAB, ROO2WTJ, ROO2RXRYRZ, ROO2BRIGHTNESS,
%   ROO2XY, DWL
%

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: roo2prop.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([1 1 2 0],[0 1 5],@i_roo2prop,varargin{:});
	error(err)

