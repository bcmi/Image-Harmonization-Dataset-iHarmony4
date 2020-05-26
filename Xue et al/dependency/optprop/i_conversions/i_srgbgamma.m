function rgb=i_srgbgamma(rgb,Dir,varargin)
%I_SRGBGAMMA Apply the special SRGB gamma function to RGB data.
%   ARGB=I_SRGBGAMMA(RGB,DIR) with size(RGB)=[M 3] returns matrix ARGB with
%   same size.
%
%   DIR is the direction of gamma conversion. Linear RGB values are converted
%   to nonlinear by DIR='inverse' and nonlinear sRGB values to linear RGB
%   by DIR='forward'.
%
%   [...]=I_SRGBGAMMA(..., 'CLIP', C) with C={'on'|'off'} enables or disables
%   input limiting between [0,1]. Default 'on'.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use SRGBGAMMA instead.
%
%   Example:
%      To convert linear rgb values to nonlinear rgb, use:
%
%	      i_srgbgamma([.1 .1 .1], 'inverse')
%
%   See also SRGBGAMMA,LAB2RGB, XYZ2RGB, RGB2LAB, RGB2XYZ

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_srgbgamma.m 24 2007-01-28 23:20:35Z jerkerw $


	Default=struct('Clip', 'on');
	par=args2struct(Default, varargin);
	if strcmp(par.Clip,'on')
		rgb(rgb>1)=1;
		rgb(rgb<0)=0;
		end
	switch partialmatch(Dir, {'forward', 'inverse'})
		case 'inverse'
			ix=rgb>0.0031308;
			rgb(ix)=1.055*(rgb(ix).^(1/2.4)) - 0.055;
			rgb(~ix)=12.92*rgb(~ix);
		case 'forward'
			ix=rgb>0.04045;
			rgb(ix)=((0.055+rgb(ix))/1.055).^2.4;
			rgb(~ix)=rgb(~ix)/12.92;
		end
