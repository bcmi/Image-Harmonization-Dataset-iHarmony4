function rgb=i_rgb2rgb(rgb, Src, Dst, varargin)
%I_RGB2RGB Convert from one RGB space into another.
%   ARGB=RGB2RGB(RGB,SRCTYPE, DSTTYPE) with size(RGB)=[M 3]
%   returns matrix ARGB with same size.
%
%   SRCTYPE asn DSTTYPE are one of the predefined RGB types or a conforming
%   struct, see RGBS. If omitted or empty, the default RGBTYPE,
%   OPTGETPREF('WorkingRGB'), is used.
%
%   [...]=RGB2RGB(..., 'SRCGAMMA', G) applies G instead of the default gamma
%   stipulated for the SRCTYPE.
%
%   [...]=RGB2RGB(..., 'DSTGAMMA', G) applies 1/G instead of the default gamma
%   stipulated for the DSTTYPE.
%
%   [...]=RGB2RGB(..., 'CAT', C) with string C, defines which chromatic
%   adaptation transform to use. C can be one of 'none', 'xyz', 'bradford'
%   or 'vonkries'. Default = 'bradford'.
%
%   [...]=RGB2RGB(..., 'CLASS', C) with M={'double'|'single'|'uint16'|'uint8'} converts
%   the output to CLASS C, instead of the default, which is the same as the input.
%
%   [...]=RGB2RGB(..., 'CLIP', C) with C={'on'|'off'} enables or disables
%   limiting between [0,1]. Default 'on'
%
%   Remark:
%   Remember that when converting from a wider RGB space into a smaller,
%   clipping may occur, so that e.g.
%      rgb2rgb(rgb2rgb(rgb,'srgb','adobe'),'adobe','srgb') ~= rgb
%
%   Example:
%      Visualize where in RGB-space data get changed the most when
%      converting from sRGB to Adobe RGB
%
%         r=colorchecker(400:10:700);
%         r=reshape(r,[],length(400:10:700));
%         srgb=i_roo2rgb(r,'srgb',400:10:700);
%         argb=i_rgb2rgb(srgb,'srgb','adobe');
%         % DE works with any cartesian system ...
%         dr=de(srgb,argb);
%         ballplot(srgb,srgb,dr,3);
%         camlight;
%         lighting phong
%
%   See also: RGB2RGB, MAKECWF, RGBS, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_rgb2rgb.m 24 2007-01-28 23:20:35Z jerkerw $

	Defaults=struct( ...
		  'SrcGamma', [] ...
		, 'DstGamma', [] ...
		, 'Cat', 'bradford' ...
		, 'Class', class(rgb) ...
		, 'Clip', 'on' ...
		);
	par=args2struct(Defaults,varargin);
	s=rgbs(Src);
	Parm={'Cat', par.Cat, 'Clip', par.Clip};
	xyz=i_rgb2xyz(rgb,Src,s.IllObs  , 'Gamma', par.SrcGamma, Parm{:});
	rgb=i_xyz2rgb(xyz,s.IllObs,Dst, 'Gamma', par.DstGamma, Parm{:});
	clear xyz
	rgb=i_rgbcast(rgb, par.Class);
