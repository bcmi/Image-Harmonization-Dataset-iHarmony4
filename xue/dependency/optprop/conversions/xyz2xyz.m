function varargout=xyz2xyz(varargin)
%XYZ2XYZ Adapt XYZ to another illuminant/observer.
%   AXYZ=XYZ2XYZ(XYZ,CWFSRC,CWFDST) with size(XYZ)=[M N ... P 3] returns
%   matrix AXYZ with same size.
%
%   AXYZ=XYZ2XYZ(X,Y,Z,CWFSRC,CWFDST) with size(X,Y,Z)=[M N ... P] returns
%   matrix AXYZ with size [M N ... P 3].
%
%   [AX,AY,AZ]=XYZ2XYZ(XYZ,CWFSRC,CWFDST) with size(XYZ)=[M N ... P 3] returns
%   matrices AX, AY and AZ, each with size [M N ... P].
%
%   [AX,AY,AZ]=XYZ2XYZ(X,Y,Z,CWFSRC,CWFDST) with size(X,Y,Z)=[M N ... P]
%   returns equally sized matrices AX, AY and AZ.
%
%   CWFSRC and CWFDST are color weighting function specifications. They can
%   be strings, e.g. 'D50/2', or structs, see MAKECWF. If omitted or empty,
%   the default cwf, DCWF is used.
%
%   ...=XYZ2XYZ(...,'CAT',C) with string C, defines which
%   chromatic adaptation transform to use. C can be one of 'none' 'xyz',
%   'bradford' or 'vonkries'. Default = 'bradford'.
%
%   Example:
%      axyz=xyz2xyz([30 30 30],'D65/10','D50/2', 'CAT', 'bradford');
%
%   See also LAB2LAB, RGB2RGB

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: xyz2xyz.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([3 2 0 2],[1 1],@i_xyz2xyz,varargin{:});
	error(err);
	end
