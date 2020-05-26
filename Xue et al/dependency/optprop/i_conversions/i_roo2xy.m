function xy=i_roo2xy(Roo, cwf, wl)
%I_ROO2XY Convert from spectra to chromaticity x and y.
%   XY=I_ROO2XY(ROO,CWF,WL) with size(ROO)=[M W] returns matrix XY with
%   same size.
%
%   ROO holds M spectral readings with W spectral bands and WL, size [1 W],
%   holds the wavelengths. If WL is empty, the default wavelength range,
%   DWL, is used for WL.
%
%   CWF is a color weighting function specification. It can be a
%   string, e.g. 'D50/2', or a struct, see MAKECWF. If empty, the
%   the default cwf, OPTGETPREF('cwf') is used.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use ROO2XY instead.
%
%   Example:
%      Show a Macbeth ColorChecker in xy-space
%
%         cc=reshape(colorchecker(dwl),[],length(dwl));
%         xy=i_roo2xy(cc,'D50/2',dwl);
%         rgb=i_roo2rgb(cc, 'srgb',dwl);
%         helmholtz;
%         hold on
%         scatter(xy(:,1),xy(:,2),200,rgb,'filled');
%         hold off
%         axis equal
%
%   See also: ROO2XY, MAKECWF, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_roo2xy.m 24 2007-01-28 23:20:35Z jerkerw $

	xy=i_xyz2xy(roo2xyz(Roo, cwf, wl));
