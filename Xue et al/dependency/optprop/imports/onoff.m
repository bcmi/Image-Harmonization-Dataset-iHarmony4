function y=onoff(x)
%ONOFF ON/OFF to/from Boolean Conversion.
% ONOFF(S) where S is the case insensitive string 'on' or 'off' returns
% logical True for 'on' and False for 'off'.
%
% ONOFF(C) where C is a cell array of strings containing the strings 'on'
% or 'off', returns a logical array the same size as C containing True
% where 'on' appears and False where 'off' appears.
%
% ONOFF(B) where B is True or False, returns the string 'on' for True and
% 'off' for False.
%
% ONOFF(A) where A is a logical array, returns a cell array of strings the
% same size as A containing 'on' where True appears and 'off' where False
% appears.

% D.C. Hanselman, University of Maine, Orono, ME 04469
% MasteringMatlab@yahoo.com
% Mastering MATLAB 7
% 2006-01-15

	if ischar(x) && strcmpi(x,'on')
	   y=true;
	elseif ischar(x) && strcmpi(x,'off')
	   y=false;
	elseif iscellstr(x)
	   y=strcmpi(x,'on');
	elseif islogical(x) && numel(x)==1
	   d={'off' 'on'};
	   y=d{x+1};
	elseif islogical(x)
	   y=cell(size(x));
	   y(x)={'on'};
	   y(~x)={'off'};
	else
	   error('Improper Input.')
	end