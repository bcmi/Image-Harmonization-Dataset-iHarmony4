function rgb=i_xyz2disp(xyz,IllObs,varargin)
%I_XYZ2DISP Convert from XYZ to display realizable RGB.
%   RGB=I_XYZ2DISP(XYZ,CWF) with size(XYZ)=[M 3] returns matrix RGB with
%   same size.
%
%   CWF is a color weighting function specification. It can be a
%   string, e.g. 'D50/2', or a struct, see MAKECWF. If empty, the
%   the default cwf, OPTGETPREF('cwf') is used.
%
%   ...=XYZ2DISP(...,'class', RGBCLASS) casts the result into class
%   specified by RGBCLASS. RGBCLASS can be any one of 'double', 'single'
%   'uint16' or 'uint8'. If empty or omitted, OPTGETPREF('DisplayClass')
%   is used.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use XYZ2DISP instead.
%
%   See also: XYZ2DISP, MAKECWF, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_xyz2disp.m 24 2007-01-28 23:20:35Z jerkerw $

	Default=struct('class', optgetpref('DisplayClass'));
	par=args2struct(Default, varargin);
	rgbout=rgbs(optgetpref('DisplayRGB'));
	rgb=i_rgbcast(i_xyz2rgb(xyz,IllObs,rgbout),par.class);
