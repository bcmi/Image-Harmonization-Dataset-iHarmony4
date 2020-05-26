function z=isilluminant(x)
%ISILLUMINANT Check for valid illuminant specification

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: isilluminant.m 23 2007-01-28 22:55:34Z jerkerw $

	lenx=length(x);
	x=upper(x);
	z=	isempty(x) ...
		|| ischar(x) ...
			&& ( ...
				(lenx==1 && any('ACE'==x)) ...
				|| (lenx==3 || lenx==5) ...
					&& any('DP'==x(1)') ...
					&& all('0'<=x(2:end) & x(2:end)<='9') ...
				|| (lenx==2 || lenx==3) && x(1)=='F' && isnumchar(x(2:end),1:12) ...
				);

function z=isnumchar(x,valids)
	y=str2double(x);
	if ~isempty(y)
		z=ismember(y,valids);
	else
		z=false;
		end
