%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function success = generateemptyfile(fileName)
%GENERATEEMPTYFILE  Generate empty file.
%		GENERATEEMPTYFILE(FILE) generates an empty file with the given name.
%
%		Markus Buehren
%		Last modified 08.01.2009
%
%   See also FOPEN.

try
	[fid, message] = fopen(fileName, 'w');
catch
	fid = -1;
	% do nothing
end

if fid == -1
	disp(message);
	success = 0;
else
	fclose(fid);
	success = 1;
end
