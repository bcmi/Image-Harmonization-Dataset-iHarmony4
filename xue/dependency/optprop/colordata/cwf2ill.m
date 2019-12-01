function z=cwf2ill(illobs)
%CWF2ILL Extract the illuminant from a color weigting functoins specification
%   Z=CWF2ILL(CWF) returns the iluminant of the specified CWF as a char array.
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%   See also: MAKECWF, DCWF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: cwf2ill.m 23 2007-01-28 22:55:34Z jerkerw $

	if nargin==0 || isempty(illobs)
		illobs=dcwf;
		end
	if ischar(illobs)
		ix=find(illobs=='/',1);
		if ix
			illobs=illobs(1:ix-1);
			end
		z=illobs;
	elseif iscwf(illobs)
		z=illobs.illuminant;
	else
		error(illpar('Argument not an illuminant'));
		end
	z=upper(z);

