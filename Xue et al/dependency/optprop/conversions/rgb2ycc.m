function varargout=rgb2ycc(varargin)
%RGB2YCC Converts from RGB to YCbCr.
%   YCC=RGB2YCC(RGB) with size(RGB)=[M N ... P 3] returns matrix YCC with
%   same size.
%
%   YCC=RGB2YCC(R,G,B) with size(R,G,B)=[M N ... P] returns matrix YCC with
%   size [M N ... P 3].
%
%   [Y,C,C]=RGB2YCC(RGB) with size(RGB)=[M N ... P 3] returns matrices Y, C
%   and C, each with size [M N ... P].
%
%   [Y,C,C]=RGB2YCC(R,G,B) with size(R,G,B)=[M N ... P] returns equally
%   sized matrices Y, C and C.
%
%   [...]=RGB2YCC(..., 'CLASS', CL) with CL={'double'|'single'|'uint16'|'uint8'} converts
%   the output to CLASS C, instead of the default, which is the same as the input.
%
%   [...]=RGB2YCC(..., 'CLIP', C) with C={'on'|'off'} enables or disables
%   limiting output values. Clipping is enabled by default. If clipping is
%   enabled, the output is limited within following ranges for different
%   output classes:
%
%      Class                 Y                CbCr
%      double,single  [16/255 235/255]  [16/255 240/255]
%      uint8              [16 235]          [16 240]
%      uint16           [4112 60395]      [4112 61680]
%
%   Example:
%      rgb2ycc(uint8([50 50 50]), 'class', 'double')
%
%   See also: YCC2RGB, I_RGB2YCC

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: rgb2ycc.m 24 2007-01-28 23:20:35Z jerkerw $

%   Constants from Charles Poynton's "Color FAQ" Eq 3

	[err,varargout{1:max(1,nargout)}]=optproc([3 0 0 2],[],@i_rgb2ycc,varargin{:});
	error(err);
