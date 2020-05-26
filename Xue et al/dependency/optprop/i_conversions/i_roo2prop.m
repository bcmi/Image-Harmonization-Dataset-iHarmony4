function PropArr=i_roo2prop(Roo, Prop, IllObs, wl)
%I_ROO2PROP Convert from spectra to various optical properties.
%
%   Z=I_ROO2XYZ(ROO, PROPS, CWF, WL) with size(ROO)=[M W],
%   char array PROPS size [1 P] and row vector WL, size [1 W], returns matrix Z
%   with size [M P].
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
%   WL specifies the wavelengths of the spectra.
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If empty, the default cwf,
%   OPTGETPREF('cwf') is used.
%
% Example:
%      Get the Lab and CIE Whiteness into a [1 4] row vector
%         z=i_roo2prop(100*ones(1,length(dwl)),'LabW','D65/10',dwl)
%
%   See also: ROO2XYZ, ROO2LAB, ROO2WTJ, ROO2RXRYRZ, ROO2BRIGHTNESS,
%   ROO2XY, DWL
%

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_roo2prop.m 43 2007-02-06 16:18:35Z jerkerw $

	Prop=PropExchange(Prop,'RxRyRz', 'åäö');
	ixB=Prop=='B';
	ixXYZ=~ixB;
	PropArr(:,ixXYZ) = i_xyz2prop(roo2xyz(Roo, IllObs,wl), Prop(ixXYZ), IllObs);
	if sum(ixB) > 0
		PropArr(:,ixB)= repmat(i_roo2brightness(Roo,wl),1,sum(ixB));
		end
