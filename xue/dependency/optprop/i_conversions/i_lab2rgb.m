function rgb=i_lab2rgb(Lab, IllObs, Type, varargin)
%I_LAB2RGB Convert from Lab to RGB.
%   RGB=I_LAB2RGB(LAB,CWF,RGBTYPE) with size(LAB)=[M 3] returns
%   matrix RGB with same size.
%
%   CWF is a color weighting function specification. It can be a
%   string, e.g. 'D50/2', or a struct, see MAKECWF. If empty, the
%   the default cwf, OPTGETPREF('cwf') is used.
%
%   RGBTYPE is one of the predefined RGB types or a conforming struct, see RGBS.
%   If empty, the default RGBTYPE, OPTGETPREF('WorkingRGB'), is used.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use LAB2RGB instead.
%
%   Example:
%      Convert a scaled down rosch space into sRGB
%
%		  spec=rosch(31);
%         sz=size(spec);
%         spec=reshape(spec,[],31);
%         lab=.8*i_roo2lab(spec,'D50/2',400:10:700);
%         rgb=i_lab2rgb(lab,'D65/10','srgb');
%         rgb=reshape(rgb,[sz([1 2]) 3]);
%         lab=reshape(lab,[sz([1 2]) 3]);
%         % Show the result
%         subplot(121);viewlab(lab,rgb);
%         subplot(122);viewgamut(rgb,rgb);axis([0 1 0 1 0 1]);
%
%   See also: LAB2RGB, I_RGB2LAB, MAKECWF, RGBS, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_lab2rgb.m 24 2007-01-28 23:20:35Z jerkerw $

	rgb=i_xyz2rgb(i_lab2xyz(Lab, IllObs), IllObs, Type, varargin{:});
