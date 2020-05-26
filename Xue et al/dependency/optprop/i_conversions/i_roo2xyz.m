function xyz=i_roo2xyz(roo, cwf, wl,varargin)
%I_ROO2XYZ Convert from spectra to XYZ
%   XYZ=ROO2XYZ(ROO,CWF,WL) with size(ROO)=[M W] returns matrix XYZ with
%   size [M 3].
%
%   ROO holds M spectral readings with W spectral bands and WL, size
%   [1 W], holds the wavelengths. If WL is empty and W equals the
%   length of the default wavelength range, DWL, this
%   wavelength range is used for WL.
%
%   CWF specifies an color weighting function specification. It can be a
%   string, e.g. 'D50/2', or a struct, see MAKECWF. If empty, the default
%   cwf, OPTGETPREF('cwf') is used.
%
%   ROO holds spectral readings with W spectral bands and WL, size
%   [1 W], holds the wavelengths. If WL is omitted or empty and W equals the
%   length of the default wavelength range, DWL, this
%   wavelength range is used for WL.
%
%   Example:
%      xyz=roo2xyz(rosch);
%      viewgamut(xyz,'xyz');
%
%   See also MAKECWF, ROO2LAB, ROO2XY, OPTGETPREF

%
% This routine is in a temporary state. Eventually, if the requested CWF
% can not be supplied by ASTM, it will build its own, using the method
% described in ASTM 2022. This will induce the least overhead, since only a
% single matrix multiplication is needed.
%
% If there is anyone out there who has already implemented this scheme,
% I'll be happy to include it here, with due credit given.
%
% Until then, the spectra is interpolated down to 5 nm before it is
% multiplicated with the CMF and illuminant, with care taken to extend the
% spectra at both ends.
% 
% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_roo2xyz.m 46 2007-03-28 08:52:17Z jerkerw $

	if isstruct(cwf)
		if length(varargin)>0
			warning('optprop:i_roo2xyz:IgnoringExtra', 'Ignoring named parameters when CWF is struct');
			end
	else
		cwf=makecwf(cwf,wl,varargin{:});
		end
	if cwf.docompensation
		roo=stearns(roo);
		end
	if ~isequal(cwf.wl,wl)
		roo=interproo(cwf,roo,wl);
		end
	xyz=roo*cwf.weights/100;

function z=interproo(cwf,roo,wl)
	% It's quite useful to allow NaN interpolation. See e.g. ROSCH
	ws=warning('off','MATLAB:interp1:NaNinY');
	z=interp1(wl,roo',cwf.wl)';
	if isvector(z); z=z'; end
	if ~isempty(z)
		z(:,cwf.wl<wl(1))=roo(1);
		z(:,cwf.wl>wl(end))=roo(end);
		end
	warning(ws);
	
function z=stearns(x)
	a=.083;
	z=[
		(1+a)*x(:,1)-a*x(:,2) ...
		-a*x(:,1:end-2)+(1+2*a)*x(:,2:end-1)-a*x(:,3:end) ...
		(1+a)*x(:,end)-a*x(:,end-1)
		];
