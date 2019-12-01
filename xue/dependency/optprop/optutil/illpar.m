function z=illpar(msg,varargin)
%ILLPAR Return illegal parameter error struct.

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: illpar.m 23 2007-01-28 22:55:34Z jerkerw $

	if isstruct(msg)
		msg=regexprep(msg.message,'^Error using ==> .*\n','');
	else
		msg=sprintf(msg,varargin{:});
		end
	z=struct('identifier','optprop:IllPar', 'message', msg);
