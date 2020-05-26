function varargout=xyz2disp(varargin)
%XYZ2DISP Convert from XYZ to RGB.
%   RGB=XYZ2DISP(XYZ,CWF) with size(XYZ)=[M N ... P 3] returns
%   matrix RGB with same size.
%
%   RGB=XYZ2DISP(X,Y,Z,CWF) with size(X,Y,Z)=[M N ... P] returns
%   matrix RGB with size [M N ... P 3].
%
%   [R,G,B]=XYZ2DISP(XYZ,CWF) with size(XYZ)=[M N ... P 3] returns
%   matrices R, G and B, each with size [M N ... P].
%
%   [R,G,B]=XYZ2DISP(X,Y,Z,CWF) with size(X,Y,Z)=[M N ... P]
%   returns equally sized matrices R, G and B.
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%   ...=XYZ2DISP(...,'class', RGBCLASS) casts the result into class
%   specified by RGBCLASS. RGBCLASS can be any one of 'double', 'single'
%   'uint16' or 'uint8'. If empty or omitted, OPTGETPREF('DisplayClass')
%   is used.
%
%   See also: MAKECWF, OPTGETPREF, I_XYZ2DISP

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: xyz2disp.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([3 0 1 1],1,@i_xyz2disp,varargin{:});
	error(err);
