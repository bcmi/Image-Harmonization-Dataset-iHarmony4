function rgb=i_xy2rgb(xy, IllObs, Type)
%I_XY2RGB Convert from XY to visually pleasing RGB.
%    I_XY2RGB converts xy values to corresponding RGB values, assuming
%    maximum Y, as defined by the Rösch color solid.
%
%   RGB=I_XY2RGB(XY,CWF,RGBTYPE) with size(XY)=[M 2] returns matrix RGB with
%   size [M 3].
%
%   CWF is a color weighting function specification. It can be a
%   string, e.g. 'D50/2', or a struct, see MAKECWF. If empty, the
%   the default cwf, OPTGETPREF('cwf') is used.
%
%   RGBTYPE is one of the predefined RGB types or a conforming struct, see RGBS.
%   If empty, the default RGBTYPE, OPTGETPREF('WorkingRGB'), is used.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use XY2RGB instead.
%
%   See also: XY2RGB, MAKECWF, RGBS, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_xy2rgb.m 24 2007-01-28 23:20:35Z jerkerw $

	rgb=i_xyz2rgb(i_xy2xyz(xy, IllObs), IllObs, Type);
