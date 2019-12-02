function varargout=luv2lab(varargin)
%LUV2LAB Convert from LUV to LAB.
%   LAB=LUV2LAB(LUV,CWF) with size(LUV)=[M N ... P 3] returns
%   matrix LAB with same size.
%
%   LAB=LUV2LAB(L,U,V,CWF) with size(L,U,V)=[M N ... P] returns
%   matrix LAB with size [M N ... P 3].
%
%   [L,A,B]=LUV2LAB(LUV,CWF) with size(LUV)=[M N ... P 3] returns
%   matrices L, A and B, each with size [M N ... P].
%
%   [L,A,B]=LUV2LAB(L,U,V,CWF) with size(L,U,V)=[M N ... P]
%   returns equally sized matrices L, A and B.
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%   Example:
%      luv2lab([60 80 30], 'D50/2')
%
%   See also: LAB2LUV, MAKECWF, OPTGETPREF, I_LUV2LAB

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: luv2lab.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([3 0 1 0],1,@i_luv2lab,varargin{:});
	error(err);
