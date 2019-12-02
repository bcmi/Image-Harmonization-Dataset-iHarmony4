function stringOut = textwrap2(stringIn, nOfColumns)
%TEXTWRAP2  Wrap text string.
%		OUT = TEXTWRAP2(IN, COL) wraps the given text string IN to fit into COL
%		columns. The results is a string with line breaks '\n' inserted.
%
%		OUT = TEXTWRAP2(IN) uses a default number of 75 columns.
%
%		Note: This function uses the Matlab-function TEXTWRAP which returns a
%		cell array with each cell containing one line of text.
%
%		Example:
%		disp(textwrap2(myString, 75));
%
%		Markus Buehren
%		Last modified 21.04.2008
%
%		See also TEXTWRAP.

stringOut = '';
if nargin < 2
	nOfColumns = 75;
end
if ischar(stringIn)
	stringIn = {stringIn}; % function textwrap requires a cell array as input
end

stringOutCell = textwrap(stringIn, nOfColumns);
for k=1:length(stringOutCell)
	stringOut = [stringOut, stringOutCell{k}, sprintf('\n')]; %#ok
end
stringOut(end) = ''; % remove last line break
