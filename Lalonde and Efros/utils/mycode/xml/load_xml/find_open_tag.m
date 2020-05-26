% A helper function for parsing xml.  Given a string containing xml and a
% tag name, search for the first occurrence of either '<tagName ' or 
% '<tagName>'.
%
% Author: Joe Rollo
%
% Some code was taken from parseXMLelement.m
%
% Input: 
% -xml a string with xml.
% -tagName which tag to search for
%
% Output: 
% -tagLoc the location of the opening angle bracket of the first occurrence
% of the tag, or -1 if the tag cannot be found.
% -tagLength the length of the full tag string from '<' to '>', or 0 if no 
% tag was found.
%
function [tagLoc, tagLength] = find_open_tag(xml, tagName)

tagLoc    = -1;
tagLength = 0;

numChars = length(xml);

% Search for open tags with no attributes.
jTagNoAttr   = strfind(xml, ['<' tagName '>']);

% Search for open tags with attributes.
jTagWithAttr = strfind(xml, ['<' tagName ' ']);

jOpenTags = [jTagNoAttr, jTagWithAttr];

if ~isempty(jOpenTags)
    
    % Get the first occurrence of an open tag.
    tagLoc = min(jOpenTags);
    
    % Find the location of the closing tag.
    jClose = strfind(xml(tagLoc:numChars), '>');
    
    if isempty(jClose)
        
        % No closing bracket for the tag.
        error('find_open_tag: no closing bracket for tag %s at position %d', ...
                tagName, tagLoc);
        tagLoc = -1;
        return;
    end
    
    % Figure out the size of the tag in chars, including the '<' and '>'
    % signs.
    tagLength = jClose(1) - tagLoc + 1;
end

% Else there were no open tags.
     