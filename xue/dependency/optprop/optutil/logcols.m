function y=logcols(d1,d2,p,n)
%LOGCOLS logarithically spaced column vectors.
%   LOGCOLS(x1, x2, N) generates a matrix with
%   logarithmically spaced points between starting vector x1
%   and ending vector x2.
%
%   Example:
%	    logcols([0 10 20],[6 20 50],.005,4)
%
%   See also LINSPACE

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: logcols.m 23 2007-01-28 22:55:34Z jerkerw $

if nargin < 4; n=100; end
if isempty(d1)
	y=[];
else
	Guard00=d1==0 & d2==0;
	y =[
		d1
		real(fun( ...
		  (repmat(ifun(d1,p),n-2,1) ...
		+ repmat(ifun(d2,p)-ifun(d1,p),n-2,1).*repmat((1:n-2)',1,size(d1,2))/(n-1)),p))
		d2];
	y(:,Guard00)=0;
	end

function z=fun(x,p)
	z=exp(x)-p;

function z=ifun(x,p)
	z=log(x+p);
