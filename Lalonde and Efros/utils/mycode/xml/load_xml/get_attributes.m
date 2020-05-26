% A helper function for parsing xml.  Given the contents of an xml header
% tag, retrieve the attribute names and values.
%
% Author: Joe Rollo
%
% Input:
% -xml the xml string containing the tag header.
%
% Output:
% -names cell array of attribute name strings (empty if there are no 
% attributes)
% -values cell array of attribute value strings (empty if there are no 
% attributes)
%
function [names, values] = get_attributes(tag)

% If there are any angle brackets, get rid of them.
tag = strrep(tag, '<', '');   % Replace with empty string here.
tag = strrep(tag, '/>', ' '); % Replace with a space here.
tag = strrep(tag, '>', ' ');  % Replace with a space here.

% Start at the first space after the tag header's name, assuming there are
% no spaces before the tag header's name.
spaces = strfind(tag, ' ');

if isempty(spaces)
    
    error('get_attributes: no spaces in the tag.');
end

iChar = spaces(1);

% Look for quotes in the tag.
quotesInTag = strfind(tag, '"');

% Count the number of attributes (one equals sign for each attribute).
signsInTag = strfind(tag, '=');

% Remove the '=' signs between two quotes
tmpInd = arrayfun(@(x) find(x < quotesInTag, 1, 'first') - find(x > quotesInTag, 1, 'last') & mod(find(x > quotesInTag, 1, 'last'), 2)==1, signsInTag, 'UniformOutput', 0);
tmpNonEmptyInd = cellfun(@(x) ~isempty(x), tmpInd);
signsInTagInd = ones(size(signsInTag));
signsInTagInd(tmpNonEmptyInd) = ~cell2mat(tmpInd(tmpNonEmptyInd));

signsInTag = signsInTag(logical(signsInTagInd));

numAttributes = length(signsInTag);

names  = cell(numAttributes,1);
values = cell(numAttributes,1);



if length(quotesInTag) < (2*numAttributes)

    error('get_attributes: each value needs to be in quotes.');
end


% Parse each attribute
for iAttr = 1:numAttributes
    
    % The position of the current attribute's equals sign. 
    equalsSignLoc = signsInTag(iAttr);
    
    % The text between the current position and the next equals sign
    % contains the attribute name.
    name = strtrim(deblank(tag(iChar:equalsSignLoc-1)));
    
    % The position of the current attribute's value quotes.
    quoteBegin = quotesInTag( (iAttr*2)-1 ) + 1; % one after the first quote
    quoteEnd   = quotesInTag( iAttr*2 ) - 1;     % one before the second quote
    
    if (quoteBegin > quoteEnd)
        
        % Empty string value.
        value = '';
    else
        value = tag(quoteBegin:quoteEnd);
    end
   
    names{iAttr} = name;
    values{iAttr} = value;
    
    iChar = quoteEnd+2;
end
