function optpropdemo
%OPTPROPDEMO Show various features of the toolbox.
%   OPTPROPDEMO starts a browser window with a demo explaining various
%   features of the OPTPROP toolbox.

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: optpropdemo.m 23 2007-01-28 22:55:34Z jerkerw $

	p=fileparts(mfilename('fullpath'));
	fn=fullfile(p,'html','optpropdemo_src.html');
	system(['"' fn '" @']);
