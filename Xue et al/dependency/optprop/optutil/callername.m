function z=callername
%CALLERNAME Return name of caller function.
%   Z=CALLERNAME assigns the name of the caller of the caller of CALLERNAME
%   to Z. Used primarily for generating descriptive error messages.

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: callername.m 23 2007-01-28 22:55:34Z jerkerw $

	s=dbstack;
	if 3<=length(s)
		z=s(3).name;
	else
		z='base';
		end

	
