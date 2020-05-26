function z=isobserver(x)
%ISOBSERVER Check for valid observer specification

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: isobserver.m 23 2007-01-28 22:55:34Z jerkerw $

	z=~isempty(observer(x));
