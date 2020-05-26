function y=powcols(d1,d2,p,n)
%POWCOLS power spaced column vectors.
%   POWCOLS(x1, x2, P, N) generates a matrix with
%   equally power of P spaced points between starting vector x1
%   and ending vector x2.
%
%   E.g:
%			POWCOLS(([0 10 20],[6 20 50],3,4))
%
%   generates:
%
%			0.00  10.00  20.00
%			0.22  12.83  28.03
%			1.78  16.15  37.96
%			6.00  20.00  50.00
%
%   See also LINSPACE

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: powcols.m 33 2007-01-29 22:26:35Z jerkerw $

	if nargin < 4; n = 100; end
	if isempty(d1)
		y=[];
	else
		p1=1/p;
		y =[ ...
			  (repmat(d1.^p1,n-1,1) ...
			+ repmat(d2.^p1-d1.^p1,n-1,1).*repmat((0:n-2)',1,size(d1,2))/(n-1))
			d2.^p1 ...
			].^p;
		end
