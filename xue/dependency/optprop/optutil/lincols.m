function y=lincols(d1,d2,n)
%LINCOLS Linearly spaced column vectors.
%   LINCOLS(x1, x2, N) generates a matrix with
%   equally spaced points between starting vector x1
%   and ending vector x2.
%
%   E.g:
%			LINCOLS(([0 10 20],[6 20 50],3))
%
%   generates:
%
%			0		10		20
%			3		15		35
%			6		20		40
%
%   See also LINSPACE 

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: lincols.m 23 2007-01-28 22:55:34Z jerkerw $

if ~isempty(d1)
	y=[repmat(d1,n-1,1)+repmat(d2-d1,n-1,1).* repmat((0:n-2)',1,size(d1,2))/(n-1);d2];
else
	y=[];
	end
