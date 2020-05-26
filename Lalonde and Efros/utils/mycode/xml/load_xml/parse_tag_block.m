% A helper function for parsing xml.  Given an xml tag block in string form, 
% parse the tag's attributes and text/children.  
%
% Author: Joe Rollo
%
% Input:
% -xml the xml string containing the tag.
% -tagName the name of the tag.
%
% Output: if the tag has children, then the return value is a structure
% containing the this tag's subtree of fields.  Otherwise, the return
% value is a string containing the tag's text.
%
function theStruct = parse_tag_block(xml, tagStr)

tagName = tagStr;

% Check for attributes.
equalSignsInTag = strfind(tagName, '=');

if ~isempty(equalSignsInTag)
    
    % Remove any tag attributes from the tag name.
    tagName = strtok(tagName);
end

tagClose = ['</' tagName '>'];

[openTagLoc, openTagLength] = find_open_tag(xml, tagName);
jTagEnd   = strfind(xml, tagClose);

if ( (openTagLoc < 0) || isempty(jTagEnd))
    
    % The input xml is supposed to have an open and close tag pair that
    % matches the tag name.
    error('parse_tag: missing begin/end tag.');
end

%% Parse the attributes

theStruct = [];

tagEnd = openTagLoc + openTagLength;

tag = xml(openTagLoc:tagEnd);

% Get attribute names and values.
[names, values] = get_attributes(tag);

numNames = length(names);

% Add attribute fields to the struct.
for iAttr = 1:numNames
   
    value = values(iAttr);
    
    % Make sure that the value is not a cell.
    if iscell(value)
        value = value{1};
    end
    
    attrName = char(names(iAttr));
    if strfind(attrName, ':')
        attrName = strrep(attrName, ':', '');
    end
    
    theStruct.(attrName) = value;
end


%% Parse the text

% Find the beginning and end of the tag's contents.
textBegin = openTagLoc + openTagLength;
textEnd   = jTagEnd(length(jTagEnd)) - 1;

% The xml without the beginning and end tags.
xmlSub = xml(textBegin:textEnd);

% Parse the tag's text.
theStruct = parse_text(theStruct, xmlSub);
