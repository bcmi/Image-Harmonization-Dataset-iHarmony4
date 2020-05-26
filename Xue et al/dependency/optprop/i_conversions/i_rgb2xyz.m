function xyz=i_rgb2xyz(rgb,Type,IllObs,varargin)
%I_RGB2XYZ Convert from RGB to XYZ.
%   XYZ=I_RGB2XYZ(RGB,RGBTYPE,CWF) with size(RGB)=[M 3] returns
%   matrix XYZ with same size.
%
%   RGBTYPE is one of the predefined RGB types or a conforming struct, see RGBS.
%   If empty, the default RGBTYPE, OPTGETPREF('WorkingRGB'), is used.
%
%   CWF is a color weighting function specification. It can be a
%   string, e.g. 'D50/2', or a struct, see MAKECWF. If empty, the
%   the default cwf, OPTGETPREF('cwf') is used.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use RGB2XYZ instead.
%
%   Example:
%      Convert the corners of the RGB cube to XYZ
%         rgb=cat(3,[0 1 1 0 0 0 1 1],[0 0 1 1 1 0 0 1],[0 0 0 0 1 1 1 1]);
%         rgb=reshape(rgb,[],3);
%         xyz=i_rgb2xyz(rgb,'srgb', 'D65/10');
%         % Show the result
%         subplot(121);ballplot(rgb,rgb,.1,2);camlight;
%         subplot(122);ballplot(xyz,rgb,10,2);camlight;
%
%   See also: RGB2XYZ, I_XYZ2RGB, MAKECWF, RGBS, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_rgb2xyz.m 24 2007-01-28 23:20:35Z jerkerw $

	Defaults=struct('Gamma', [], 'cat', 'bradford', 'clip','on');
	par=args2struct(Defaults, varargin);
	rt=rgbs(Type);
	rgb=rgbcast(rgb,'double');
	if isempty(par.Gamma) && isa(rt.Gamma, 'function_handle')
		rgb=rt.Gamma(rgb,'forward', 'clip', par.clip);
	else
		if strcmp('clip','on')
			rgb(rgb<0)=0;
			rgb(1<rgb)=1;
			end
		if isempty(par.Gamma)
			rgb=rgb.^(rt.Gamma);
		else
			rgb=rgb.^(par.Gamma);
			end
		end
	xyz=rgb*i_xyy2xyz(rt.xyy);
	xyz=i_xyz2xyz(xyz,rt.IllObs,IllObs, 'cat', par.cat);
