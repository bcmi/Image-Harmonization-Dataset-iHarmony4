function z=iswlrange(wl)
%ISWLRANGE Indicate whether a wavelength range is valid.

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: iswlrange.m 23 2007-01-28 22:55:34Z jerkerw $

	z=false;
	if isempty(wl)
		z=true;
	elseif isvector(wl) && isa(wl,'double') && length(wl)>1
		df=diff(wl);
		if all(df>0) && all(df==df(1)) && all(rem(df,1)==0)
			z=true;
			end
		end
