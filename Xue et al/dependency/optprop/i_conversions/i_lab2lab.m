function dlab=i_lab2lab(lab, cwfs, cwfd, varargin)
%I_LAB2LAB Adapt LAB to another illuminant/observer.
%   ALAB=I_LAB2LAB(LAB,CWFS,CWSD) with size(LAB)=[M 3] returns matrix ALAB
%   with same size. The Lab values are converted from being relative the
%   illuminant/observer implied by CWFS into being relative to the ones in
%   CWFD.
%
%   CWFS and CWSD are a color weighting function specifications. They can
%   be a strings, e.g. 'D50/2', or structs, see MAKECWF. If empty, the
%   default cwf, OPTGETPREF('cwf') is used.
%
%   ...=I_LAB2LAB(...,'cat',C) with string C, defines which chromatic
%   adaptation transform to use. C can be any one of 'none' 'xyz',
%   'bradford' or 'vonkries'. Default is 'bradford'.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use LAB2LAB instead.
%
%   Example:
%      Convert Lab value from the illuminant/observer (D65/10) to
%      D50/2 and visualize the difference in Lab values.
%
%         cchk=reshape(colorchecker(400:10:700),[],31);
%         lab=i_roo2lab(cchk,'D65/10',400:10:700);
%         alab=i_lab2lab(lab,'D65/10','D50/2','cat','bradford');
%         rgb=i_lab2disp(lab,'D65/10'); % Use D65/10 colors
%         d=de(lab,alab);
%         ballplot(lab(:,[2 3 1]),rgb,d+1);
%         camlight;
%		  lighting phong
%
%   See also LAB2LAB, MAKECWF, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_lab2lab.m 23 2007-01-28 22:55:34Z jerkerw $

	sxyz=i_lab2xyz(lab,cwfs);
	dxyz=i_xyz2xyz(sxyz,cwfs, cwfd, varargin{:});
	dlab = i_xyz2lab(dxyz,cwfd);
