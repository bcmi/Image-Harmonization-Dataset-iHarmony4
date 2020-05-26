function z=isrgbclass(t)
% ISRGBTYPE Indicates whether input is a valid RGB class.

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: isrgbclass.m 23 2007-01-28 22:55:34Z jerkerw $

	z=isempty(t) || ischar(t) && any(strcmpi(t,{'uint8', 'uint16','single', 'double'}));
