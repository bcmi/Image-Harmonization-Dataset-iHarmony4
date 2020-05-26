%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function theStruct = readStructFromXML(filename)
%  Reads a MATLAB structure from an XML file.
% 
% Input parameters:
%   - theStruct: actual matlab structure to write to
%   - filename : name of the .xml file
%
% Output parameters:
%
% Warnings:
%   - An xml file stores everything in strings, and has no way of knowing
%     the type of a particular attribute. It is up to the application to
%     convert the recovered data to the desired type.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function theStruct = readStructFromXML(filename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    % read the document
    docNode = xmlread(filename);
    
    % build the structure from the document
    theStruct = [];
    
    % add the fields of the structure to the document
    theStruct = addNode(docNode.getDocumentElement);
 
catch
    err = lasterror;
    error('Failed to read XML file %s: ',filename, err.message);
end

function theStruct = addNode(curNode)
    % read all its attributes
    nodeMap = curNode.getAttributes;
    if ~isempty(nodeMap)
        for i=0:nodeMap.getLength-1;
            att = nodeMap.item(i);
            
            % check if the attribute already exists
            % add its value to the structure
            theStruct.(char(att.getName)) = char(att.getValue);
        end
    end
    
    % read all its children
    childNodes = curNode.getChildNodes;
    if ~isempty(childNodes)
        for i=0:childNodes.getLength-1

            childNode = childNodes.item(i);
            % make sure it's an element and ignore the other types
            if (childNode.getNodeType == childNode.ELEMENT_NODE)
                ind = 1;
                if exist('theStruct', 'var') && isfield(theStruct, char(childNode.getTagName))
                    ind = size(theStruct.(char(childNode.getTagName)),2) + 1;
                end

                % add the children as a new struct
                nodeToAdd = addNode(childNode);
                if ischar(nodeToAdd)
                    theStruct.(char(childNode.getTagName)) = nodeToAdd;
                elseif ind == 1
                    theStruct.(char(childNode.getTagName))(ind) = nodeToAdd;
                else
                    names = fieldnames(nodeToAdd);
                    for j=1:length(names)
                        theStruct.(char(childNode.getTagName)) = ...
                            setfield(theStruct.(char(childNode.getTagName)), {1,ind}, names{j}, nodeToAdd.(names{j}));
                    end
                end
%             elseif (childNode.getNodeType == childNode.TEXT_NODE)
%                 data = char(childNode.getData);
%                 l = length(data);
%                 % filter out weird characters
%                 data = data(double(data) >= 32 & double(data) <= 127);
%                 if ~isempty(data)
%                     % first and last characters are LF (line feed) 
%                     theStruct = data;
%                 elseif l > 1
%                     theStruct = '';
%                 end
            end
        end
    end
    
return;
