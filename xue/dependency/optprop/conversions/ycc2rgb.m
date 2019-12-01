function varargout=ycc2rgb(varargin)
%YCC2RGB Convert from YCbCr to RGB.
%   RGB=YCC2RGB(YCC) with size(YCC)=[M N ... P 3] returns
%   matrix RGB with same size.
%
%   RGB=YCC2RGB(Y,CB,CR) with size(Y,CB,CR)=[M N ... P] returns
%   matrix RGB with size [M N ... P 3].
%
%   [R,G,B]=YCC2RGB(YCC) with size(YCC)=[M N ... P 3] returns
%   matrices R, G and B, each with size [M N ... P].
%
%   [R,G,B]=YCC2RGB(Y,CB,CR) with size(Y,CB,CR)=[M N ... P]
%   returns equally sized matrices R, G and B.
%
%   [...]=YCC2RGB(..., 'CLASS', C) with M={'double'|'single'|'uint16'|'uint8'} converts
%   the output to CLASS C, instead of the default, which is the same as the input.
%
%   [...]=YCC2RGB(..., 'CLIP', C) with C={'on'|'off'} enables or disables
%   limiting output values. Clipping is enabled by default. If clipping is
%   enabled, the output is limited within following ranges for different
%   output classes:
%
%      Class                RGB
%      double,single       [0 1]
%      uint8              [0 255]
%      uint16            [0 65535]
%
%   Example:
%      rgb=ycc2rgb([.3 .5 .4])
%
%   See also: RGB2YCC, MAKECWF, RGBS, OPTGETPREF, I_YCC2RGB

% Constants from Charles Poynton's "Color FAQ" Eq 3
% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: ycc2rgb.m 24 2007-01-28 23:20:35Z jerkerw $


	[err,varargout{1:max(1,nargout)}]=optproc([3 0 0 2],[],@i_ycc2rgb,varargin{:});
