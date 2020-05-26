function varargout=lab2xy(varargin)
%LAB2XY Convert from Lab to chromaticity coordinates x and y.
%   XY=LAB2XY(LAB,CWF) with size(LAB)=[M N ... P 3] returns
%   matrix XY with size [M N ... P 2].
%
%   XY=LAB2XY(L,A,B,CWF) with size(L,A,B)=[M N ... P] returns
%   matrix XY with size [M N ... P 2].
%
%   [X,Y]=LAB2XY(LAB,CWF) with size(LAB)=[M N ... P 3] returns
%   matrices X and Y, each with size [M N ... P].
%
%   [X,Y]=LAB2XY(L,A,B,CWF) with size(L,A,B)=[M N ... P]
%   returns equally sized matrices X and Y.
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%   Example:
%      Verify that pure grays have the same chromaticity.
%
%         xy=lab2xy([25 0 0;50 0 0;75 0 0;100 0 0])
%
%   See also: XY2LAB, MAKECWF, OPTGETPREF, I_LAB2XY

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: lab2xy.m 30 2007-01-29 22:22:44Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([3 0 1 0],1,@i_lab2xy,varargin{:});
	error(err);

