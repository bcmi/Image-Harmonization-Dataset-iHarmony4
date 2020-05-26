function [z,err]=args2struct(Defaults, Args, generror)
%ARGS2STRUCT Parse input parameters into a struct.
%   ARGS2STRUCT aids parsing of parameters, so that the call of
%   a function can contain both positional and named parameters
%   as e.g Handle Graphics calls.

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: args2struct.m 23 2007-01-28 22:55:34Z jerkerw $

	err=[];
	z=[];
	if nargin<3;generror=true;end
	if nargin==1
		z=Defaults;
		return;
		end
	fnDefaults=fieldnames(Defaults);
	[reg, prop]=parseparams(Args);
	if length(fnDefaults) < length(reg)
		err=illpar('Too many input arguments');
		if generror; error(err);else return;end
		end
	for i=1:length(reg)
		Defaults.(fnDefaults{i})=reg{i};
		end
	n=length(prop);
	if rem(n,2)
		err=illpar('Parameter/value pairs must come in PAIRS');
		if generror; error(err);else return;end
		end
	fnLowerDefaults=lower(fnDefaults);
	for i=0:n/2-1
		ixp=2*i+1;
		ix=strmatch(lower(prop{ixp}), fnLowerDefaults,'exact');
		if isempty(ix)
			ix=strmatch(lower(prop{ixp}), fnLowerDefaults);
			end
		if length(ix)==1
			Defaults.(fnDefaults{ix}) = prop{ixp+1};
		else
			if isempty(ix)
				err=illpar('Invalid named parameter: ''%s''.', prop{ixp});
			else
				err=illpar('Ambigously named parameter: ''%s''.', prop{ixp});
				end
			if generror; error(err);else return;end
			end
		end
	z=Defaults;
