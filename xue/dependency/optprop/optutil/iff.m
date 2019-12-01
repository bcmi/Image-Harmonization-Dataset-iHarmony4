function z=iff(cond,t,f)
%IFF Contitional selection.

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: iff.m 23 2007-01-28 22:55:34Z jerkerw $

	if cond
		z=t;
	else
		z=f;
		end