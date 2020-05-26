function varargout=varginfill(vargin)
%VARGINFILL Set omitted input arguments to the empty array

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: varginfill.m 23 2007-01-28 22:55:34Z jerkerw $

	tofill=nargout-length(vargin);
	if tofill<0
		error('varginfill:TooFewOutput','Too few output arguments');
	else
		fill=cell(1,tofill);
		[varargout{1:nargout}]=deal(vargin{:}, fill{:});
		end
