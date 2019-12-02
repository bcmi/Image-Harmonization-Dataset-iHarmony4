function rgb=i_ycc2rgb(ycc,varargin)
%I_YCC2RGB Convert from YCbCr to RGB.
%   RGB=I_YCC2RGB(YCC,RGBTYPE,CWF) with size(YCC)=[M 3] returns matrix RGB with
%   same size.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use YCC2RGB instead.
%
%   See also: YCC2RGB, I_RGB2YCC, MAKECWF, RGBS, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_ycc2rgb.m 24 2007-01-28 23:20:35Z jerkerw $

	Defaults=struct('Class', class(ycc), 'Clip', 'on');
	par=args2struct(Defaults, varargin);
	ycc=i_rgbcast(ycc,'double');

	iM = 255*inv([65.481 128.553 24.966; -37.797 -74.203 112;112 -93.786 -18.214])';
	O = 1/255*[16 128 128];
	rgb=(ycc-O(ones(size(ycc,1),1),:))*iM;
	if onoff(par.Clip)
		rgb=max(min(rgb,1),0);
		end
	rgb=i_rgbcast(rgb,par.Class);
