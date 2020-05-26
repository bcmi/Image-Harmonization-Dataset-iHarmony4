function rgb=i_xyz2rgb(xyz,IllObs,Type,varargin)
%I_XYZ2RGB Convert from XYZ to RGB.
%   RGB=I_XYZ2RGB(XYZ,CWF,RGBTYPE) with size(XYZ)=[M 3] returns matrix RGB with
%   same size.
%
%   CWF is a color weighting function specification. It can be a
%   string, e.g. 'D50/2', or a struct, see MAKECWF. If empty, the
%   the default cwf, OPTGETPREF('cwf') is used.
%
%   RGBTYPE is one of the predefined RGB types or a conforming struct, see RGBS.
%   If empty, the default RGBTYPE, OPTGETPREF('WorkingRGB'), is used.
%
%   [...]=XYZ2RGB(..., 'GAMMA', G) applies 1/G instead of the default gamma
%   specified for the RGBTYPE.
%
%   [...]=XYZ2RGB(...,'CAT',C) with string C, defines which chromatic
%   adaptation transform to use. C can be one of 'none', 'xyz', 'bradford'
%   or 'vonkries'. Default = 'bradford'.
%
%   [...]=XYZ2RGB(..., 'CLIP', C) with C={'on'|'off'} enables or disables
%   output limiting between [0,1]. Default 'on'
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use XYZ2RGB instead.
%
%   Example:
%      z=i_xyz2rgb([30 40 50],'D50/2','srgb')
%
%   See also: XYZ2RGB, I_RGB2XYZ, MAKECWF, RGBS, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_xyz2rgb.m 24 2007-01-28 23:20:35Z jerkerw $

	% Handle possible parameters
	Defaults=struct('Gamma', [], 'cat', 'bradford', 'Clip', 'on');
	par=args2struct(Defaults,varargin);
	rt=rgbs(Type);
	if isa(rt, 'function_handle')
		% Undocumented so far. We'll see when I get around to implement this.
		% User want to do the conversion himself through an ICC profile.
		% start by converting to D50/2.
		xyz=i_xyz2xyz(xyz,IllObs,'D50/2', 'cat', par.cat);
		rgb=rt(xyz);
	else
		xyz=i_xyz2xyz(xyz,IllObs,rt.IllObs, 'cat', par.cat);
		rgb=xyz*inv(i_xyy2xyz(rt.xyy));
		if isempty(par.Gamma) && isa(rt.Gamma, 'function_handle')
			rgb=rt.Gamma(rgb,'inverse', 'Clip', par.Clip);
		else
			if strcmpi(par.Clip, 'on')
				rgb(rgb<0)=0;
				rgb(1<rgb)=1;
				end
			if isempty(par.Gamma)
				rgb=rgb.^(1/rt.Gamma);
			else
				rgb=rgb.^(1/par.Gamma);
				end
			end
		end
