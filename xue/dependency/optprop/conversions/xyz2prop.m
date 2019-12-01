function varargout=xyz2prop(varargin)
%XYZ2PROP Convert from tristimulus XYZ to various optical properties.
%
%   A=XYZ2PROP(XYZ, PROPS, CWF), where size(XYZ)=[M N ... O 3],
%   char array PROPS size [1 P], returns matrix A with size [M N ... O P].  
%
%   [A1,A2,...,AP]=XYZ2PROP(XYZ, PROPS, CWF), where size(XYZ)=[M N ... O 3]
%   and char array PROPS size [1 P], returns matrices A1,A2,...,AP, each
%   with size [M N ... O].
%
%   A=XYZ2PROP(X,Y,Z, PROPS, CWF), where size(X,Y,Z)=[M N ... O] and char
%   array PROPS size [1 P], returns matrix A with size [M N ... O P].
%
%   [A,B,C, ...]=XYZ2PROP(XYZ,PROPS,CWF) returns A,B,C,... each
%   with size [M N ... O].
%
%   [A1,A2,...,AP]==XYZ2PROP(X,Y,Z, PROPS, CWF), where size(X,Y,Z)=
%   [M N ... O] and char array PROPS size [1 P], returns matrices
%   A1,A2,...,AP, each with size [M N ... O].
%
%   PROPS can be any one of 'LabWTJXYZxy' and/or any of 'Rx','Ry','Rz'.
%   These specifiers are case sensitive. PROPLEN is the number of speci-
%   fiers in PROPS, where 'Rx', 'Ry' and 'Rz' counts as one specifier.
%   
%      L  CIE L*          W  CIE Whiteness
%      a  CIE a*          T  CIE Tint
%      b  CIE b*          J  Yellowness
%      X  CIE X           Rx
%      Y  CIE Y           Ry
%      Z  CIE Z           Rz
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%
% Example:
%      Get the Lab and CIE Whiteness of the D65/10 whitepoint under D65/2
%      into a [1 4] row vector:
%
%         z=xyz2prop(wpt('D65/10'),'LabW','D65/2')
%
%   See also: I_XYZ2PROP, XYZ2LAB, XYZ2WTJ, XYZ2RXRYRZ,ROO2XY

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: xyz2prop.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([3 1 1 0],[0 1],@i_xyz2prop,varargin{:});
	error(err);
