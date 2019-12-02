%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function writeStructToXML(theStruct, filename)
%  Writes a MATLAB structure to an XML file.
% 
% Input parameters:
%   - theStruct: actual matlab structure to write to
%   - filename : name of the .xml file
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function writeStructToXML(theStruct, filename, documentName)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin == 2
    documentName = 'document';
end

try
    % create an empty XML document
    docNode = com.mathworks.xml.XMLUtils.createDocument(documentName);
    docRootNode = docNode.getDocumentElement;
    
    % add the fields of the structure to the document
    addFields(theStruct, docNode, docRootNode);
    
    % Save the sample XML document.
    xmlwrite(filename, docNode);
catch
    err = lasterror;
    error('Failed to write XML file %s: ',filename, err.message);
end
 


function addFields(theStruct, docNode, curNode)

for k=1:length(theStruct)
    names = fieldnames(theStruct(k));
    for i=1:size(names,1)
        name = names(i);

        field = theStruct.(char(name));

        for j=1:length(field)
            % if the field is another structure, recurse into it
            if isstruct(field(j))
                % create an empty element
                newElement = docNode.createElement(name);
                addFields(field(j), docNode, newElement);

                % add it to the current node
                curNode.appendChild(newElement);

            else
                % add the value as an attribute
                if isnumeric(field) || islogical(field)
                    % make sure it only has a single element
                    if length(field) ~= 1
                        error('Field must have a single element');
                    end
                    field = num2str(field);
                elseif ~ischar(field)
                    error('Unsupported attribute');
                end
                curNode.setAttribute(name, field);
            end
        end
    end
end

return;

