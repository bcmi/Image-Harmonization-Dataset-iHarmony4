function [xyz,C,rest]=GamutColorCheck(type,varargin)
%GAMUTCOLORCHECK Checks input for graphical output routines

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: GamutColorCheck.m 23 2007-01-28 22:55:34Z jerkerw $


	len = length(varargin);
	for i = len:-2:1
		if ischar(varargin{i}) || i == 1 || ~ischar(varargin{i-1})
			break;
			end
		end
	rest = varargin(i+1:len);
	argin=varargin(1:i);
	switch length(argin)
		case 1
			xyz=argin{1};
			C=type;
		case 2
			xyz=argin{1};
			C=argin{2};
		case 3
			xyz=cat(3,x,y,z);
			C=type;
		case 4
			xyz=cat(3,x,y,z);
			C=argin{4};
		otherwise
			xyz=num2cell(type);
			error('%s: Call with (%s), (%s, C), (%s,%s,%s), (%s,%s,%s,C) or (H, ...)', callername,type,type,xyz{:},xyz{:});
		end
