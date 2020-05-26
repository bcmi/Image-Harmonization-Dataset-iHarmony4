function z=partialmatch(str,Options, noerr)
%PARTIALMATCH  Finds string matches á la Handle Graphics
%   Z=PARTIALMATCH(S,OPT) returns the string in OPT that either matches
%   exactly or unambiguously matches from the start. Comparisons are made
%   without regard to case. If no match can be established, an error is
%   raised.
%   Z=PARTIALMATCH(S,OPT, 'noerror') works like the previous but does not
%   raise an error if there is no match, instead an error message struct is
%   return with the field 'message' holding appropriate message.
%
%   Example:
%      partialmatch('abc',  {'Abc', 'abcdef'})
%      partialmatch('abcd', {'Abc', 'abcdef'})
%      partialmatch('ab'  , {'Abc', 'abcdef'})
%
%   See also: STRCMP, STRCMPI, STRMATCH, PARTIALINDEX

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: partialmatch.m 23 2007-01-28 22:55:34Z jerkerw $

	if nargin<3 || isempty(noerr)
		noerr=false;
	else
		if isempty(strmatch(lower(noerr), 'noerror'))
			error('partialmatch:IllPar', 'Third argument can only be empty or ''noerror''');
			end
		noerr=true;
		end
	ix=find(strcmpi(str, Options));
	if ~isempty(ix)
		z=Options{ix};
	else
		ix=strmatch(lower(str), lower(Options));
		switch length(ix)
			case 0
				z=struct( ...
					  'message', sprintf('Option ''%s'' is not valid', str) ...
					, 'identifier', 'PartialMatch:NoMatch');
			case 1
				z=Options{ix};
			otherwise
				z=struct( ...
					  'message', sprintf('Option ''%s'' is ambiguous', str) ...
					, 'identifier', 'PartialMatch:AmbiguousMatch');
			end
		if isstruct(z) && ~noerr
			error(z);
			end
		end
	end
