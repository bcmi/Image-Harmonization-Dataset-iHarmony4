function ycc=i_rgb2ycc(rgb, varargin)
%I_RGB2YCC Converts from RGB to YCbCr.
%   YCC=I_RGB2YCC(RGB) with size(RGB)=[M 3] returns matrix YCC with same
%   size.
%
%   [...]=RGB2YCC(..., 'class', C) with M={'double'|'single'|'uint16'|'uint8'} converts
%   the output to CLASS C, instead of the default, which is the same as the input.
%
%   [...]=RGB2YCC(..., 'clip', C) with C={'on'|'off'} enables or disables
%   limiting output values. Clipping is enabled by default. If clipping is
%   enabled, the output is limited within following ranges for different
%   output classes:
%
%      Class                 Y                CbCr
%      double,single  [16/255 235/255]  [16/255 240/255]
%      uint8              [16 235]          [16 240]
%      uint16           [4112 60395]      [4112 61680]
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use RGB2YCC instead.
%
%   Example:
%      i_rgb2ycc(uint8([50 50 50]), 'class', 'double')
%
%   See also: RGB2YCC, I_YCC2RGB

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_rgb2ycc.m 24 2007-01-28 23:20:35Z jerkerw $

	Defaults=struct('Class', class(rgb), 'Clip', 'on');
	par=args2struct(Defaults, varargin);
	rgb=i_rgbcast(rgb,'double');
	M = 1/255*[65.481 128.553 24.966; -37.797 -74.203 112;112 -93.786 -18.214]';
	O = 1/255*[16 128 128];
	ycc=rgb*M+O(ones(size(rgb,1),1),:);
	if onoff(par.Clip)
		ycc=max(ycc,16/255);
		ycc(:,1)=min(ycc(:,1),235/255);
		ycc(:,[2 3])=min(ycc(:,[2 3]),240/255);
		end
	ycc=i_rgbcast(ycc,par.Class);
