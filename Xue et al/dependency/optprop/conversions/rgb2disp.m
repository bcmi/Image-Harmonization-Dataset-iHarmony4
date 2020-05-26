function varargout=rgb2disp(varargin)
%RGB2DISP Convert from RGB to display RGB space.
%   RGB2DISP converts RGB values into RGB values that are realizable on the
%   display specified by OPTGETPREF('DisplayRGB').
%
%   RGB=RGB2DISP(RGB, RGBTYPE) with size(RGB)=[M N ... P 3] returns
%   matrix RGB with same size.
%
%   RGB=RGB2DISP(R,G,B,RGBTYPE) with size(R,G,B)=[M N ... P] returns
%   matrix RGB with size [M N ... P 3].
%
%   [R,G,B]=RGB2DISP(RGB,RGBTYPE) size(RGB)=[M N ... P 3] returns
%   matrices R, G and B, each with size [M N ... P].
%
%   [R,G,B]=RGB2DISP(R,G,B,RGBTYPE) with size(R,G,B)=[M N ... P] returns
%   matrices R, G and B, with same size [M N ... P].
%
%   RGBTYPE is one of the predefined RGB types or a conforming struct, see
%   RGBS. If omitted or empty, the default RGBTYPE, OPTGETPREF('WorkingRGB'),
%   is assumed.
%
%   ...=RGB2DISP(...,'class', RGBCLASS) casts the result into class
%   specified by RGBCLASS. RGBCLASS can be any one of 'double', 'single'
%   'uint16' or 'uint8'. If empty or omitted, OPTGETPREF('DisplayClass')
%   is used.
%
%   Example:
%      image(rgb2disp(roo2rgb(colorchecker)));
%      axis image
%
%   See also: RGBS, OPTGETPREF, I_RGB2DISP

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: rgb2disp.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([3 0 1 1],4,@i_rgb2disp,varargin{:});
	error(err);

