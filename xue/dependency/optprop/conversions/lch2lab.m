function varargout=lch2lab(varargin)
%LCH2LAB Convert from LCh to Lab.
%   LAB=LCH2LAB(LCH) with size(LCH)=[M N ... P 3] returns
%   matrix LAB with same size.
%
%   LAB=LCH2LAB(L,C,H) with size(L,C,H)=[M N ... P] returns
%   matrix LAB with size [M N ... P 3].
%
%   [L,A,B]=LCH2LAB(LCH) with size(LCH)=[M N ... P 3] returns
%   matrices L, A and B, each with size [M N ... P].
%
%   [L,A,B]=LCH2LAB(L,C,H) with size(L,C,H)=[M N ... P]
%   returns equally sized matrices L, A and B.
%
%   See also: LAB2LCH, MAKECWF, OPTGETPREF, I_LCH2LAB

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: lch2lab.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([3 0 0 0],[],@i_lch2lab,varargin{:});
	error(err);
