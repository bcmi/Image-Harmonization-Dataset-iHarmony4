function z=lineup(x,y)
%LINEUP Lines up x so it "fits" line or row vector y

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: lineup.m 23 2007-01-28 22:55:34Z jerkerw $

	if ~isvector(y)
		error(illpar('second argument must be line vector'));
		end
	if isempty(x)
		z=[];
		return;
		end
	szx=size(x);
	szy=size(y);
	
	if szy(1)==1
		if szx(1)==szy(2)
			z=x';
		elseif szx(2)==szy(2)
			z=x;
		else
			error(illpar('Can not line up first argument'));
			end
	else
		if szx(2)==szy(1)
			z=x';
		elseif szx(1)==szy(1)
			z=x;
		else
			error(illpar('Can not line up first argument'));
			end
		end
		
			