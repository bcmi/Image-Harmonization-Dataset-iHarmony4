function varargout=rgbcast(varargin)
%RGBCAST Convert RGB from one numeric represenation to another.
%   ARGB=RGBCAST(RGB,CASTTO) with size(RGB)=[M N ... P 3]
%   returns matrix ARGB with same size.
%
%   ARGB=RGBCAST(R,G,B,CASTTO) with size of R,G,B = [M N ... P]
%   returns matrix ARGB with size [M N ... P 3].
%
%   [AR,AG,AB]=RGBCAST(RGB,CASTTO) size(RGB)=[M N ... P 3] returns
%   matrices AR, AG and AB, each with size [M N ... P].
%
%   [AR,AG,AB]=RGBCAST(R,G,B,CASTTO) size(R,G,B)=[M N ... P] returns
%   returns equally sized matrices AR, AG and AB.
%
%   CASTTO is any one of 'double', 'single' 'uint16' or 'uint8', converts
%   the image to CASTTO representation. If omitted or empty, the default
%   OPTGETPREF('DisplayRGB') is used.
%
%   Example:
%      Convert limits of an uint8 image to double
%         rgb=rgbcast(uint8([255 255 255;0 0 0]), 'double')
%
%   See also: RGBCAST, RGBS, I_RGBCAST

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: rgbcast.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([3 1 0 0],7,@i_rgbcast,varargin{:});
	error(err);

