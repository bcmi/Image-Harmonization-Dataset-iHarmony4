function varargout = regexptokens(str, expr)
%REGEXPTOKENS  Get tokens using regular expressions.
%		[TOKEN1, TOKEN2, ...] = REGEXPTOKENS(STRING, EXPRESSION) returns the
%		tokens returned by function REGEXP in a cell array. 
%
%		Example:
%		fileNr = regexptokens('radarsim3_19_rdd.mat', 'radarsim3_(\d+)')
%
%		Markus Buehren
%
%		See also REGEXP.

[s,f,t] = regexp(str, expr, 'once'); %#ok

argout = cell(nargout, 1);
if isempty(t)
	varargout = argout;
	return
else
	for n=1:nargout
		
		% for compatibility to Matlab 7.2
		if isnumeric(t)
			t = {t}; %#ok
		end
		
		if (size(t{1},1) >= n) && ~isempty(t{1}) && ~any(t{1}(n,:) == 0)
			argout{n} = str(t{1}(n,1):t{1}(n,2));
		else
			argout{n} = '';	
		end
	end
	varargout = argout;
end
