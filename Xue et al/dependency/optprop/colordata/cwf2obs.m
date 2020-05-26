function z=cwf2obs(IllObs)
%CWF2OBS Extract the observer from a color weigting functoins specification
%   Z=CWF2OBS(CWF) returns the observer of the specified CWF as a char array.
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%   See also: MAKECWF, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: cwf2obs.m 24 2007-01-28 23:20:35Z jerkerw $

	if nargin==0 || isempty(IllObs)
		IllObs=dcwf;
		end
	if ischar(IllObs)
		ix=find(IllObs=='/',1);
		if ix
			IllObs=IllObs(ix+1:end);
			end
		z=IllObs;
	elseif iscwf(IllObs)
		z=IllObs.observer;
	else
		error(illpar('Argument not an observer'));
		end
	z=upper(z);
