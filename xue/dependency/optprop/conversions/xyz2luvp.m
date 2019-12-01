function varargout=xyz2luvp(varargin)
%XYZ2LUVP Convert from XYZ to LU'V'.
%   LUVP=XYZ2LUVP(XYZ,CWF) with size(XYZ)=[M N ... P 3] returns
%   matrix LUVP with size [M N ... P].
%
%   LUVP=XYZ2LUVP(X,Y,Z,CWF) with size(X,Y,Z)=[M N ... P] returns
%   matrix LUVP with size [M N ... P].
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%   Example:
%      xyz2luvp([30 40 50], 'D50/2')
%
%   See also: LUVP2XYZ, MAKECWF, OPTGETPREF, I_XYZ2LUVP

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: xyz2luvp.m 24 2007-01-28 23:20:35Z jerkerw $


%   Author: Jerker Wågberg, 2005-03-30

	[err,varargout{1:max(1,nargout)}]=optproc([3 0 1 0],1,@i_xyz2luvp,varargin{:});
	error(err);

