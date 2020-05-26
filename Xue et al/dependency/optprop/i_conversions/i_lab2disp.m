function rgb=i_lab2disp(lab,IllObs,varargin)
%I_LAB2DISP Convert from LAB to display RGB.
%   I_LAB2DISP converts Lab values into RGB values that are realizable on the
%   display specified by OPTGETPREF('DisplayRGB').
%
%   RGB=I_LAB2DISP(LAB, ILLOBS) with size(LAB)=[M 3] returns
%   matrix RGB with same size.
%
%   CWF is a color weighting function specification. It can be a
%   string, e.g. 'D50/2', or a struct, see MAKECWF. If empty, the
%   the default cwf, OPTGETPREF('cwf') is used.
%
%   ...=I_LAB2DISP(...,'class', RGBCLASS) casts the result into class
%   specified by RGBCLASS. RGBCLASS can be any one of 'double', 'single'
%   'uint16' or 'uint8'. If empty or omitted, OPTGETPREF('DisplayClass')
%   is used.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use LAB2DISP instead.
%
%   Example:
%      Verify that a grey sample is converted into R, G and B with R=G=B:
%
%         i_lab2disp([50 0 0])
%
%    See also LAB2DISP, MAKECWF, OPTGETPREF, OPTSETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_lab2disp.m 24 2007-01-28 23:20:35Z jerkerw $

	rgb=i_xyz2disp(i_lab2xyz(lab,IllObs),IllObs,varargin{:});
