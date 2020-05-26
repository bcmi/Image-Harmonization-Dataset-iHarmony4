% A helper function for parsing xml.  Given a string containing an xml tag, 
% parse the tag name.
%
% Author: Joe Rollo
%
% Some code was taken from parseXMLelement.m
%
% Input: an xml string that contains at least one tag.
%
% Output: 
% -the name of the tag (attributes and closing slash excluded).
%
function tagName = get_tag_name(xml)


% Find the first tag.
jBegin  = strfind(xml, '<');

if isempty(jBegin)
    
    % No tags.
    error('get_tag_name: there was no tag in the input.');
end
    

% There is at least one beginning tag.

jClose  = strfind(xml, '>');

% Get the tag name--might contain attributes.
tagName = deblank(xml(jBegin(1)+1:jClose(1)-1));

% Check for attributes.
equalSignsInTag = strfind(tagName, '=');

if ~isempty(equalSignsInTag)
    
    % Remove any tag attributes from the tag name.
    tagName = strtok(tagName);
end

% Remove any slashes from the tag name (in case this is a closing tag).
tagName = strrep(tagName, '/', '');