function [v, xml] = loadXML(filename)
%
% Reads a XML file and produces a struct array.
%
% filename = name of the XML file
% v = struct variable containing fields of type char or numeric
%
% filename can also be an URL containing XML

% Read file
if ~strcmp(filename(1:5), 'http:');
    [fid, message] = fopen(filename,'r');
    if fid == -1; error(message); end
    xml = fread(fid, 'uint8=>char');
    fclose(fid);
else
    filename = strrep(filename, '\', '/');
    xml = urlread(filename);
end

% Remove 'new line' characters from the chain
xml = char(xml(:)');
xml = strrep(xml, char(10), '');
xml = strrep(xml, char(13), '');

v = xml2struct(xml);
 
 