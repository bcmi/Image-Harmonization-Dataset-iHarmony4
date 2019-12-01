function varargout=lab2disp(varargin)
%LAB2DISP Convert from LAB to display RGB.
%   LAB2DISP converts Lab values into RGB values that are realizable on the
%   display specified by OPTGETPREF('DisplayRGB').
%
%   RGB=LAB2DISP(LAB, ILLOBS) with size(LAB)=[m n ... p 3] returns
%   matrix RGB with same size.
%
%   RGB=LAB2DISP(L,A,B,ILLOBS) with size(L,A,B)=[m n ... p] returns
%   matrix RGB with size [m n ... p 3].
%
%   [R,G,B]=LAB2DISP(LAB,ILLOBS) size(LAB)=[m n ... p 3] returns
%   matrices R, G and B, each with size [m n ... p].
%
%   [R,G,B]=LAB2DISP(L,A,B,ILLOBS) with size(L,A,B)=[m n ... p] returns
%   matrices R, G and B, with same size [m n ... p].
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the the
%   default cwf, DCWF is used.
%
%   ...=LAB2DISP(...,'class', RGBCLASS) casts the result into class
%   specified by RGBCLASS. RGBCLASS can be any one of 'double', 'single'
%   'uint16' or 'uint8'. If empty or omitted, OPTGETPREF('DisplayClass')
%   is used.
%
%   Example:
%      Verify that a grey sample is converted into R, G and B with R=G=B:
%
%         lab2disp([50 0 0])
%
%    See also RGBS, MAKECWF, RGB2LAB, OPTGETPREF, OPTSETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: lab2disp.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([3 0 1 1],1,@i_lab2disp,varargin{:});
	error(err);
