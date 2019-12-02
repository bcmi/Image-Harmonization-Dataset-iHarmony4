function optsetpref(varargin)
%OPTSETPREF Set OptProp preferences.
%   OPTSETPREF('PreferenceName', PreferenceValue) sets the value of the
%   specified preference.
%
%   OPTSETPREF(A) where A is a structure whose field names are preference
%   names, sets the preferences named in each field name with the values
%   contained in the structure.
%
%   OPTSETPREF('PreferenceName1',PreferenceValue1,'PreferenceName2',PreferenceValue2,...)
%   sets multiple preference values with a single statement.
%
%   OPTSETPREF(..., TYPE) where TYPE is a char vector with the contents
%   'session' or 'default', specifies the degree of persistency of the
%   setting. 'session' specifies that the setting is valid for the rest of
%   current session or until next setting. 'default' sets the default value
%   for the preference, to be used in subsequent sessions. If this
%   parameter is left out, 'session' is assumed.
%
%   OPTSETPREF('PreferenceName')
%   displays the possible values for the specified preference.
%   
%   OPTSETPREF
%   displays all preference names and their possible values.
%
%   Remark:
%      This routine is modelled after the Handle Graphics SET command and
%      much of the above description is taken from the help text of SET.
%
%      The 'default' settings are stored using Matlab's
%      SETPREF('optprop',...)
%
%   Example:
%      Set the default illuminant/observer to D65/10 for this session:
%         optsetpref('cwf','D65/10');
%
%      Make the current preferences the default for subsequent sessions:
%         optsetpref(optgetpref,'default');
%
%   See also: OPTGETPREF, OPTPROC

% Part of the OptProp toolbox, $Version: 2.1 $
% Author: Jerker Wågberg, More Research & DPC, Sweden
% Email:  ['jerker.wagberg' char(64) 'more.se']

% $Id: optsetpref.m 23 2007-01-28 22:55:34Z jerkerw $

	type ='session';
	if nargin>0
		type = persistency(varargin{nargin});
		if isempty(type)
			type='session';
		else
			varargin(nargin)=[];
			end
		end
	nargs=length(varargin);
	if nargs==0
		usage;
		return
	elseif nargs==1 && ischar(varargin{1})
		usage(varargin{1});
		return
	elseif nargs==1
		if isstruct(varargin{1})
			setting=varargin{1};
		else
			error(illpar('Illegal arguments.'));
			end
	else
		if rem(nargs,2)==0 && all(cellfun(@ischar,varargin(1:2:nargs)))
			if all(cellfun(@isvarname,varargin(1:2:nargs)))
				setting=struct(varargin{1:nargs});
			else
				error(illpar('Illegal parameter name'));
				end
		else
			error(illpar('Parameter/values must come in pairs'));
			end
		end

	fn=fieldnames(setting);
	for i=1:length(fn);
		name=partialmatch(fn{i},optpref);
		Val=setting.(fn{i});
		AllValid=valids;
		switch name
			case 'ASTM'
				if ~ischar(Val)
					error(illpar('ASTM argument must be char array'));
					end
				Val=partialmatch(Val, AllValid.ASTM, 'noerr');
				if isstruct(Val)
					error(Val);
					end
			case 'DisplayClass'
				if isempty(Val) || ~isrgbclass(Val)
					error(illpar('Not a valid RGB class'));
				else
					Val=lower(Val);
					end
			case 'SpectrumType'
				Val=partialmatch(Val,AllValid.SpectrumType);
			case 'ChunkSize'
				if ~isscalar(Val) || ~isa(Val, 'double') || Val <= 0
					error(illpar('ChunkSize must be a positive scalar double'));
					end
				% optproc caches Chunksize for speed.
				% Make sure he reads it fresh next time.
				clear optproc
			case 'cwf'
				if ~iscwf(Val) || isempty(Val)
					error(illpar('Illegal color weighting function specification'));
					end
			case {'WorkingRGB','DisplayRGB'}
				% Let rgbs do the error checking
				try
					rgbs(Val);
				catch
					% Pretend the error was found in this routine
					error(illpar(lasterror));
					end
			case 'WLRange'
				if isvector(Val) && isa(Val,'double') && all(diff(Val)>0)
					Val=Val(:)';
				else
					error(illpar('Wavelength range must be an monotonously increasing double vector'));
					end
			end
		optpref('set',name,type,Val);
		end
	end

function z=validIllObs
	if strcmp(optgetpref('ASTM'), 'only')
		z=strrep(fieldnames(astm('cwf'))','_','/');
	else
		z={'A/2','A/10','C/2','C/10','Dxx/2','Dxx/10','E/2','E/10','F2/2','F7/2','F7/10','F11/2','F11/10'};
		end
	end

function z=valids
	z=struct( ...
		  'ASTM'			, {{'off', 'first', 'only'}} ...
		, 'SpectrumType'	, {{'compensated','uncompensated'}} ...
		, 'ChunkSize'		, '' ...
		, 'CWF'				, {validIllObs} ...
		, 'WorkingRGB'		, {rgbs} ...
		, 'DisplayRGB'		, {rgbs} ...
		, 'DisplayClass'	, {{}} ... % uses isdisplayclass
		, 'WLRange'			, '' ...
		);
		end

function usage(name)
	function z=optstring(x)
		if iscellstr(x)
			z=strcat(x(:),{' | '})';
			z=[z{:}];
			z=['[ ' z(1:end-2) ']'];
		else
			z='';
			end
		end

	v=valids;
	if nargin==0
		for name=fieldnames(v)'
			val=optstring(v.(name{:}));
			if isempty(val)
				disp(name{:});
			else
				disp([name{1} ': ' val ]);
				end
			end
	else
		name=partialmatch(name,fieldnames(v),'noerr');
		if isstruct(name)
			error(illpar(name));
			end
		val=optstring(v.(name));
		if isempty(val)
			disp(sprintf('Preference ''%s'' does not have a fixed set of preference values', name));
		else
			disp(val);
			end
		end
	end
