function varargout=lab2lch(varargin)
%LAB2LCH Convert from Lab to LCH.
%   LCH=LAB2LCH(LAB) with size(LAB)=[M N ... P 3] returns matrix LCH with
%   same size.
%
%   LCH=LAB2LCH(L,A,B) with size(L,A,B)=[M N ... P] returns matrix LCH with
%   size [M N ... P 3].
%
%   [L,C,H]=LAB2LCH(LAB) with size(LAB)=[M N ... P 3] returns matrices L, C
%   and H, each with size [M N ... P].
%
%   [L,C,H]=LAB2LCH(L,A,B) with size(L,A,B)=[M N ... P] returns equally
%   sized matrices L, C and H.
%
%   Example:
%      lab2lch([45 30 40])
%
%   See also: LCH2LAB, I_LAB2LCH

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: lab2lch.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([3 0 0 0],[],@i_lab2lch,varargin{:});
	error(err);
