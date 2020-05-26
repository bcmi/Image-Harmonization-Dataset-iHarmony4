function rgb=i_rgb2disp(rgb, type, varargin)
%I_RGB2DISP Convert from RGB to display RGB space.
%   ARGB=I_RGB2DISP(RGB,RGBTYPE) with size(RGB)=[M 3] returns matrix ARGB
%   with same size.
%
%   RGBTYPE is one of the predefined RGB types or a conforming struct, see
%   RGBS. If omitted or empty, the default RGBTYPE, OPTGETPREF('WorkingRGB'),
%   is assumed.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use RGB2DISP instead.
%
%   Example:
%      spec=colorchecker(400:10:700);
%      rgb=i_roo2rgb(reshape(spec,[],31),'adobe',400:10:700);
%      rgb=i_rgb2disp(rgb,'adobe');
%      rgb=reshape(rgb,[4 6 3]);
%      image(rgb)
%      axis image
%
%   See also: RGB2DISP, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_rgb2disp.m 24 2007-01-28 23:20:35Z jerkerw $

	rgbout=rgbs(optgetpref('DisplayRGB'));
	% see if we can take a shortcut
	outclass=optgetpref('DisplayClass');
	if isequal(rgbs(type), rgbs(rgbout))
		rgb=i_rgbcast(rgb, outclass);
	else
		rgb=i_rgbcast(rgb2rgb(rgb,type,rgbout),outclass);
		end
