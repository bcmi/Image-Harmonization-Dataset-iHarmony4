function z=PropExchange(Props,Prop2,Prop1)
	% Exchange double coded props for single character prop
	% E.g. PROPEXCHANGE('XYZRxRyRx', 'RxRyRz', 'åäö') returns 'XYZåäö'

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: PropExchange.m 23 2007-01-28 22:55:34Z jerkerw $

	z=Props;
	for i=1:length(Prop1)
		ix=strfind(z, Prop2(2*i+(-1:0)));
		z(ix) = Prop1(i);
		z(ix+1)=[];
		end
