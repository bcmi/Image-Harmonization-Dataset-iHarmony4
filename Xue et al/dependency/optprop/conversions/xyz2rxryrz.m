function varargout=xyz2rxryrz(varargin)
%XYZ2RXRYRZ Convert from XYZ to RxRyRz.
%   RXRYRZ=XYZ2RXRYRZ(XYZ,CWF) with size(XYZ)=[M N ... P 3] returns
%   matrix RXRYRZ with same size.
%
%   [RX,RY,RZ]=XYZ2RXRYRZ(XYZ,CWF) with size(XYZ)=[M N ... P 3] returns
%   matrices RX,RY and RZ with size [M N ... P].
%
%   RXRYRZ=XYZ2RXRYRZ(X,Y,Z,CWF) with size(X,Y,Z)=[M N ... P] returns
%   matrix RXRYRZ with size [M N ... P 3].
%
%   [RX,RY,RZ]=XYZ2RXRYRZ(X,Y,Z,CWF) with size(X,Y,Z)=[M N ... P] returns
%   matrices RX,RY and RZ with size [M N ... P].
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%
%   Caveat: Only works for D65/10 and C/2
%
%   Example:
%      xyz2rxryrz([20 30 40],'D65/10')
%
%   See also: MAKECWF, OPTGETPREF, I_XYZ2RXRYRZ

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: xyz2rxryrz.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([3 0 1 0],1,@i_xyz2rxryrz,varargin{:});
	error(err);
