function z=isrgbtype(t)
% ISRGBTYPE Indicates whether input is an RGB specification or not.

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: isrgbtype.m 23 2007-01-28 22:55:34Z jerkerw $

	z=isempty(t) ...
		|| ischar(t) && any(strcmpi(t,rgbs)) ...
		|| isstruct(t) && all(cellfun(@(x)isfield(t,x),{'Name' 'IllObs' 'Gamma' 'xyy'})) ...
		... || isa(t, 'function_handle'); % May allow this in the future
		;

