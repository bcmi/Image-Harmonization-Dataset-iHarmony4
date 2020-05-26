function varargout=xyz2lab(varargin)
%XYZ2LAB Convert from XYZ to LAB.
%   LAB=XYZ2LAB(XYZ,CWF) with size(XYZ)=[M N ... P 3] returns
%   matrix LAB with same size.
%
%   LAB=XYZ2LAB(X,Y,Z,CWF) with size(X,Y,Z)=[M N ... P] returns
%   matrix LAB with size [M N ... P 3].
%
%   [L,A,B]=XYZ2LAB(XYZ,CWF) with size(XYZ)=[M N ... P 3] returns
%   matrices L, A and B, each with size [M N ... P].
%
%   [L,A,B]=XYZ2LAB(X,Y,Z,CWF) with size(X,Y,Z)=[M N ... P]
%   returns equally sized matrices L, A and B.
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%   Example:
%      xyz2lab([22 18 2], 'D50/2')
%
%   See also: LAB2XYZ, MAKECWF, OPTGETPREF, I_XYZ2LAB

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: xyz2lab.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([3 0 1 0],1,@i_xyz2lab,varargin{:});
	error(err);

