function dateNr = datenum2(dateStr)
%DATENUM2  Return serial date number.
%		Note: This function is a workaround for a kind of bug in Matlab. In
%		certain versions, function DIR returns date strings not recognized by
%		function datenum.
%
%		DATENUM2(STR) returns the serial date number for the given date string
%		STR. Function DATENUM2 is a wrapper for DATENUM which replaces german
%		month abbreviations like "Okt" by the english versions like "Oct"
%		before forwarding the string to function DATENUM.
%
%		Function DATENUM2 first tries to build a date vector from the given
%		string for performance reasons. However, only date format 0
%		(dd-mmm-yyyy HH:MM:SS) is supported for this. If the given date string
%		is in a different format, the string is forwarded to function DATENUM.
%
%		Markus Buehren
%		Last modified 30.12.2008 
%
%		See also DATENUM, TRANSLATEDATESTR.

% first try if Matlab recognizes the date string
try 
	dateNr = datenum(dateStr);
	return
catch
	% do nothing
end

% now replace some strings and try again
try
	dateNr = datenum(translatedatestr(dateStr));
	return
catch
	% do nothing
end
	
% call of function datenum returned 2 errors, try to find the date number
dateNr = [];
tokenCell = regexp(dateStr, '(\d+)-(\w+)-(\d+) (\d+):(\d+):(\d+)', 'tokens');
if ~isempty(tokenCell)
	tokenCell = tokenCell{1};
end
if length(tokenCell) == 6
	% supported date format (at least it seems so)

	% get month
	month = [];
	switch lower(tokenCell{2})
		case 'jan'
			month = 1;
		case 'feb'
			month = 2;
		case {'mar', 'mär', 'mrz'}
			month = 3;
		case 'apr'
			month = 4;
		case {'may', 'mai'}
			month = 5;
		case 'jun'
			month = 6;
		case 'jul'
			month = 7;
		case 'aug'
			month = 8;
		case 'sep'
			month = 9;
		case {'oct', 'okt'}
			month = 10;
		case 'nov'
			month = 11;
		case {'dec', 'dez'}
			month = 12;
		otherwise
			% try to find the month for some chinese Matlab versions
			try
				monthCell = regexp(tokenCell{2},'(\d+)','tokens');
				if ~isempty(monthCell)
					month = str2double(monthCell{1}{1});
				end
			catch
				% do nothing
			end
	end

	if ~isempty(month) && month >= 1 && month <= 12
		dateVec = [...
			str2double(tokenCell{3}), ... % year
			month, ...                    % month
			str2double(tokenCell{1}), ... % day
			str2double(tokenCell{4}), ... % hours
			str2double(tokenCell{5}), ... % minutes
			str2double(tokenCell{6}), ... % seconds
			];
		dateNr = datenum(dateVec);
	end

end

if isempty(dateNr)
	% unknown date format
	error('The string "%s" is not recognized as a date in Matlab.', dateStr);
end
