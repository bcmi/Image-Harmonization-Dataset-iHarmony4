function z=dwl(varargin)
%DWL Return or set the session default wavelength range.
%   Z=DWL assigns the default wavelength range to Z. DWL is purly a
%   convenience funtion and be replaced by optgetprop('WLRange').
%
%   See also: OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: dwl.m 23 2007-01-28 22:55:34Z jerkerw $
	if nargin==0
		z=optgetpref('WLRange');
	else
		optsetpref('WLRange', varargin{:});
		end
