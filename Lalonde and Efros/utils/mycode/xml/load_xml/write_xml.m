% write_xml(filename, v, useAttributes)
% Write an XML structure to a file.  See load_xml.
% Author: Joe Rollo

function write_xml(filename, v, useAttributes, documentName)

if nargin <= 2
    useAttributes = 1;
    documentName = 'document';
end

if useAttributes
    
    % Save the structure with fields in attributes.
    names = fieldnames(v);
    if isempty(names(strcmp(names, 'document')))

        % No <document> tag.
        writeStructToXML(v, filename, documentName);
    else

       % Pass in the contents of the <document> tag; the write function will
       % add <document> and </document> automatically.
       writeStructToXML(v.document, filename, documentName); 
    end
else
    
    % Use the Labelme Toolbox's xml-writing function--saves fields as tags with
    % text values.
    writeXML(filename, v);
end