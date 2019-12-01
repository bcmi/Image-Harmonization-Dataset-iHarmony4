function varargout=lab2xyz(varargin)
%LAB2XYZ Convert from Lab to XYZ.
%   XYZ=LAB2XYZ(LAB,CWF) with size(LAB)=[M N ... P 3] returns
%   matrix XYZ with same size.
%
%   XYZ=LAB2XYZ(L,A,B,CWF) with size(L,A,B)=[M N ... P] returns
%   matrix XYZ with size [M N ... P 3].
%
%   [X,Y,Z]=LAB2XYZ(LAB,CWF) with size(LAB)=[M N ... P 3] returns
%   matrices X, Y and Z, each with size [M N ... P].
%
%   [X,Y,Z]=LAB2XYZ(L,A,B,CWF) with size(L,A,B)=[M N ... P]
%   returns equally sized matrices X, Y and Z.
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%   Example:
%      Verify that Lab=[100 0 0] corresponds to the whitepoint
%
%         xyz=lab2xyz([100 0 0],'D65/10');
%         white=wpt('D65/10');
%         disp(white-xyz)
%
%   See also: XYZ2LAB, MAKECWF, OPTGETPREF, I_LAB2XYZ

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: lab2xyz.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([3 0 1 0],1,@i_lab2xyz,varargin{:});
	error(err);

