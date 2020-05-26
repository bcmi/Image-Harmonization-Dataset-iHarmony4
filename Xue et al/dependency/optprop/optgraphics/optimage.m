function varargout=optimage(varargin)
%OPTIMAGE Display true color image converted to display.
%   OPTIMAGE(RGB,RGBTYPE) converts the 3-dimensional MxNx3 matrix RGB from
%   the RGBTYPE color space into the default display RGB space, given by
%   OPTGETPREF('DisplayRGB'). After this conversion, RGB is passed on to
%   Matlab's standard IMAGE for display.
%
%   OPTIMAGE(R,G,B, RGBTYPE) where R,G and B are equally sized 2-dimensinal
%   arrays, concatenates R, G, and B into a single 3-dimensional MxNx3
%   matrix and then behaves as above.
%
%   RGBTYPE is an RGB type specification, given as a char array, e.g.
%   'srgb' or as a struct, confirming to the structs returned from RGBS.
%
%   Apart from the flexible RGB handling, RGB conversion and no
%   possibility to specify the range of the x- and y-axis, OPTIMAGE behaves
%   like IMAGE.
%
%   Example:
%      Compare the difference in apperance of a colorchecker chart, when the
%      RGB values are interpreted as adobe RGB instead of the correct sRGB.
%
%      rgb=roo2rgb(colorchecker, 'srgb'); % Valid conversion to sRGB
%      subplot(121);
%      optimage(rgb,'srgb');              % Correct visualization
%      subplot(122);
%      optimage(rgb, 'adobe');            % Incorrect visualization
%
%   See also: OPTGETPREF, RGB2RGB

% Part of the OptProp toolbox, $Version: 2.1 $
% Author: Jerker Wågberg, More Research & DPC, Sweden
% Email:  ['jerker.wagberg' char(64) 'more.se']

% $Id: optimage.m 23 2007-01-28 22:55:34Z jerkerw $

	[cax,args] = axescheck(varargin{:});
	if isempty(cax); cax=gca;end
	[err,varargout{1:nargout}]=optproc([-3 0 1 inf],4,@i_optimage,args{:},'Parent', cax);
	error(err);

function h=i_optimage(rgb,rgbtype, varargin)
	% Catch errors so that possible
	% errors are raised from here
	try
		hh=image(rgb2disp(rgb,rgbtype,'class','uint8'),varargin{:});
	catch
		error(illpar(lasterror));
		end
	axis(ancestor(hh,'axes'), 'image');
	if nargout
		h=hh;
		end
