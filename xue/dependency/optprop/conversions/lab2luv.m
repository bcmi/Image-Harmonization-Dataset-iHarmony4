function varargout=lab2luv(varargin)
%LAB2LUV Convert from Lab to Luv.
%   LUV=LAB2LUV(LAB,CWF) with size(LAB)=[M N ... P 3] returns
%   matrix LUV with same size.
%
%   LUV=LAB2LUV(L,A,B,CWF) with size(L,A,B)=[M N ... P] returns
%   matrix LUV with size [M N ... P 3].
%
%   [L,U,V]=LAB2LUV(LAB,CWF) with size(LAB)=[M N ... P 3] returns
%   matrices L, U and V, each with size [M N ... P].
%
%   [L,U,V]=LAB2LUV(L,A,B,CWF) with size(L,A,B)=[M N ... P]
%   returns equally sized matrices L, U and V.
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%   Example:
%      lab2luv([30 40 50],'D50/2')
%
%   See also: LUV2LAB, MAKECMF, I_LUV2LAB, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: lab2luv.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([3 0 1 0],1,@i_lab2luv,varargin{:});
	error(err);

