% A helper function for parsing xml.  Given a string containing xml blocks
% and a tag name, find the first top-level block.
%
% Author: Joe Rollo
%
% Some code was taken from parseXMLelement.m
%
% Input: a string with xml tag blocks in the format <tag>text</tag>
% Each tag's text is allowed to contain child tags.
%
% Output: 
% -tagBlock a partition of the xml input into a substring containing a tag
% block, or an empty string if no tag blocks are found.
% -tagName the name of the first top-level tag block.  If the tag contains
% attributes, than this will also.
%
function [tagBlock, tagName] = resolve_tag_block(xml)

tagBlock = [];
tagName = '';

numChars = length(xml);

% Find the first tag.
jBegin  = strfind(xml, '<');

if isempty(jBegin)
    
    % No tags.
    return;
end
    

% There is at least one beginning tag.

jClose  = strfind(xml, '>');

% Get the first tag name.
tagName = deblank(xml(jBegin(1)+1:jClose(1)-1));
tagNameNoAttr = tagName;

% Check for attributes.
equalSignsInTag = strfind(tagName, '=');

if ~isempty(equalSignsInTag)
    
    % Remove any tag attributes from the tag name.
    tagNameNoAttr = strtok(tagName);
end

openTag  = ['<'  tagName '>'];
closeTag = ['</' tagNameNoAttr '>'];

depth = 1;
iChar = jBegin(1) + length(openTag);

% Keep looking for open or close tags (which ever comes first) until we
% find the end of the top-level tag block.  This allows for nesting of 
% tags with the same name.
while depth > 0
   
    % The xml string from the current point on.
    xmlSub = xml(iChar:numChars);
    
    % Locate opening and closing tags.
    [openTagLoc, openTagLength]  = find_open_tag(xmlSub, tagNameNoAttr);
    closeTagLocs = strfind(xmlSub, closeTag);
    
    if isempty(closeTagLocs)
        
        % We've run out of close tags.
        error('resolve_tag_block: Field  %s  is not closed', tagName);
        return;
    end
    
    % Else there is at least one close tag left.
    
    if openTagLoc >= 0
       
        % There is another open tag (not necessarily nested in this 
        % block).
        
        if openTagLoc < closeTagLocs(1)
           
            % The next tag is an opening tag: increase nesting depth.
            depth = depth + 1;           
            iChar = iChar + openTagLoc + openTagLength - 1;
        else
            % The next tag is a closing tag: decrease nesting depth.
            depth = depth - 1;
            iChar = iChar + closeTagLocs(1) + length(closeTag)-1;
        end
    else
        % There are no more open tags: decrease nesting depth.
        depth = depth - 1;
        iChar = iChar + closeTagLocs(1) + length(closeTag)-1;
    end
end

tagBlock = xml(jBegin(1):(iChar-1));
    