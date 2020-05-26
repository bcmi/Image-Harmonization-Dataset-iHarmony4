function z=persistency(x)
%ISPERSISTENCY Decides whether input is a persistency specification

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: persistency.m 23 2007-01-28 22:55:34Z jerkerw $

	if ischar(x)
		z=partialmatch(x,{'default','session'}, 'noerr');
		if isstruct(z)
			z=[];
			end
	else
		z=[];
		end
