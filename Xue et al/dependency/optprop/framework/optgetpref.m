function z=optgetpref(varargin)
%OPTGETPREF Get OptProp preferences.
%   V = OPTGETPREF('PreferenceName') returns the value of the specified
%   preference.
%  
%   V = OPTGETPREF('PreferenceName', VAL) returns VAL if VAL is not empty.
%   Otherwise, the value of the specified preference is returned.
%  
%   OPTGETPREF displays all preference names and their current values.
%
%   V = OPTGETPREF returns a structure where each field name is the name of
%   a preference and each field contains the value of that preference.
%
%   ...=OPTGETPREF(..., TYPE) where TYPE is a char vector with the contents
%   'session' or 'default', specifies which of the two persistence settings
%   to return. 'session' specifies the session setting and 'default' speci-
%   fies the preference used as default from session start. If this
%   parameter is left out, 'session' is assumed.
%
%   Remark:
%      This routine is modelled after the Handle Graphics SET command and
%      much of the above description is taken from the help text of SET.
%
%   See also: OPTGETPREF, OPTPROC

% Part of the OptProp toolbox, $Version: 2.1 $
% Author: Jerker Wågberg, More Research & DPC, Sweden
% Email:  ['jerker.wagberg' char(64) 'more.se']

% $Id: optgetpref.m 23 2007-01-28 22:55:34Z jerkerw $

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

	error(nargchk(0,2,nargs,'struct'));
	if nargs==0
		zz=allprefs(type);
	elseif nargs==1 || nargs==2 && isempty(varargin{2})
		name=partialmatch(varargin{1},optpref,'noerr');
		if isstruct(name); error(illpar(name));end
		zz=optpref('get',name,type);
	elseif nargs==2
		zz=varargin{2};
		end
	if nargout==1
		z=zz;
	else
		disp(zz);
		end

function z=allprefs(type)
	for cfield=optpref
		z.(cfield{:})=optpref('get',cfield{:},type);
		end
