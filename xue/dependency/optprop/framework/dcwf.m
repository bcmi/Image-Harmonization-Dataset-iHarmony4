function z=dcwf(varargin)
%DCWF Return the default color matching function.
%   Z=DCWF assigns the default color matching function to Z. DCWF is purly a
%   convenience funtion and can be replaced by OPTGETPREF('cwf').
%
%   See also: OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: dcwf.m 23 2007-01-28 22:55:34Z jerkerw $
	if nargin==0
		z=optgetpref('cwf');
	else
		optsetpref('cwf',varargin{:});
		end

