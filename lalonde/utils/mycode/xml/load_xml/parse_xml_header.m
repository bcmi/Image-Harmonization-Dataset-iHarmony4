% A helper function for parsing xml.  Given the contents of an xml file,
% strip away the header tags if there are any.  Then parse the contents.
%
% Author: Joe Rollo
%
% Some code was taken from parseXMLelement.m
%
% Input: a string containing the entire contents of an xml file.
%
% Output: a structure containing xml data.

function theStruct = parse_xml_header(xml)

numChars = length(xml);

% Where the xml data begins in the string.
dataStart = 1;

% Search for xml header closing brackets.
jHeadClose  = strfind(xml, '?>');

if ~isempty(jHeadClose)
   
   % This xml file contains header tags.  Skip these.
   dataStart = max(jHeadClose)+2;
end

% The xml string with no header tags.
xmlSub = xml(dataStart:numChars);
 
% Treat the whole file as one big text field (possibly containing
% child tags).
theStruct = parse_text([], xmlSub);
