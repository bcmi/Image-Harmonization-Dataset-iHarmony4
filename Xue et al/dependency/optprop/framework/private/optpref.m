function z=optpref(op, name, type, val)
%OPTPREF Handle get and set of preferences
%   Very little formal error checking since this is not ment to be called
%   directly by the user and there are some performance issues.

% Part of the OptProp toolbox, $Version: 2.1 $
% Author: Jerker Wågberg, More Research & DPC, Sweden
% Email:  ['jerker.wagberg' char(64) 'more.se']

% $Id: optpref.m 23 2007-01-28 22:55:34Z jerkerw $

	% Pref is a structure holding the session preferences
	persistent Pref;
	persistent Names;  % Make this persistent for speed. It's called a lot...
	
	if isempty(Pref)
		% First time here. Get the session defaults
		% Start with assuming there is no previously stored settings
		Names={            'ASTM' 'ChunkSize' 'DisplayRGB' 'DisplayClass' 'cwf' 'SpectrumType'  'WLRange'  'WorkingRGB'};
		Pref =cell2struct({'first' 1e7         'srgb'       'double'         'D50/2' 'uncompensated' 400:10:700 'srgb'}, Names,2);
		for cfield=Names
			tmp=optpref('get', cfield{1}, 'default');
			if ~isempty(tmp)
				Pref.(cfield{1})=tmp;
				end
			end
		end
	if nargin==0
		z=Names;
	else
		app='optprop';
		if strcmp(op,'get')
			if strcmp(type, 'default')
				if ispref(app,name)
					z=getpref(app, name);
				else
					z=[];
					end
			else
				z=Pref.(name);
				end
		elseif strcmp(op, 'set')
			if strcmp(type, 'default')
				setpref(app, name, val);
			else
				Pref.(name)=val;
				end
		else
			error(illpar('Illegal command'));
			end
		end
