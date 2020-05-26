% A helper function for parsing xml.  Given the contents of an xml file
% or the text of an xml tag and a struct to put fields in, search for 
% attributes and child tags.  If there are child tags, recursivly parse the 
% tags.
%
% If there are attributes but no child tags (just text), then put the text
% in a field called 'text'.
%
% If there are neither attributes nor child tags, return a string value
% containing the text.
%
% If there is a name collision between an attribute and a child tag, then
% the child tag will overwrite the attribute field.
%
% Author: Joe Rollo
%
% Some code was taken from parseXMLelement.m
%
% Input: 
% -fieldStruct: add fields to this struct, then return the result.  Pass in
% as an empty array to start a new struct.
% -xml: a string with xml tag blocks in the format <tag>text</tag>
% Each tag's text is allowed to contain child tags.
%
% Output: 
% -theStruct a structure containing parsed attributes and text/child tags.

function theStruct = parse_text(fieldStruct, xml)

theStruct = fieldStruct;

%% Count the number of top-level children.

numChars = length(xml);

numChildren = 0;
xmlSub = xml;
done = 0;

while ~done

    tagBlock = resolve_tag_block(xmlSub);
    %[tagBlock, tagName] = resolve_tag_block(xmlSub);

    if isempty(tagBlock)
        
        % No more top-level tag blocks.
        done = 1;
    else
        
        % Got a top level tag block.
        numChildren = numChildren + 1;
            
        nextTagBlockBegin = length(tagBlock) + strfind(xmlSub, '<');
        
        xmlSub = xmlSub(nextTagBlockBegin:numChars);
        numChars = length(xmlSub);
    end
end

%% Leaf node check.

if numChildren == 0
   
    % There are no children.  So this is just text.
    
    if isempty(theStruct)
        
        % There are no attributes either.  Return the text in string form.
        theStruct = xml;
        
    elseif ~isempty(xml)
        
        % A tag with attributes and non-empty text: use a text field.
        theStruct.text = {xml};
    end
    
    return;
end


%% Populate arrays of tag blocks and tag names.

tagBlocks    = cell(numChildren, 1);
tagNames     = cell(numChildren, 1);

xmlSub = xml;

for iChild = 1:numChildren

    numChars = length(xmlSub);
    
    % Get a tag block and its name.
    [tagBlocks{iChild}, tagStr] = resolve_tag_block(xmlSub); 
    
    tagNames{iChild} = get_tag_name(['<' tagStr '>']);
    
    % Go to the next tag block.
    nextTagBlockBegin = length(tagBlocks{iChild}) + strfind(xmlSub, '<');

    xmlSub = xmlSub(nextTagBlockBegin:numChars);
end


%% Get unique names, name counts, and repetition indices

% Unique numbers for tags with the same name, or 1 for unique tag names.
% A repetition array index for each child.
indices      = zeros(numChildren, 1);

uniqueNames = unique(tagNames);

nameCounts = zeros(length(uniqueNames),1);


for iName = 1:numChildren
   
    whichUniqueName = strcmp(uniqueNames,tagNames{iName});
    
    nameCounts(whichUniqueName) = nameCounts(whichUniqueName) + 1;
    
    indices(iName) = nameCounts(whichUniqueName);
end


%% Parse the child tags into struct fields.

for iChild = 1:numChildren
   
    tagName = tagNames(iChild);
    fieldIndex = indices(iChild);
    
    xml = tagBlocks(iChild);
    tagNameStr = tagName{1};
    
    % Parse an individual tag (recursive call).
    parsedTag = parse_tag_block(xml{1}, tagNameStr);
    
    whichUniqueName = strcmp(uniqueNames,tagName);
    nameCount = nameCounts(whichUniqueName);
    
    if nameCount> 1
        
        % If the tag contains a string of data, put the string in a cell.
        if ischar(parsedTag)
            parsedTag = {parsedTag};
            
        elseif  isstruct(parsedTag)
            
            if fieldIndex > 1
            
                % Make sure that this tag has the same structure as 
                % previous repetitions.

                curFieldNames  = fieldnames(parsedTag);
                prevFieldNames = fieldnames(theStruct.(tagNameStr)(1));
                fieldNames = unique([curFieldNames; prevFieldNames]);
                numFieldNames = length(fieldNames);
                numStructs = length(theStruct.(tagNameStr));
                
                for iField = 1:numFieldNames;
                    
                    fieldName = fieldNames{iField};
                    
                    if ~isfield(theStruct.(tagNameStr)(1), fieldName)
                    
                        theNewStruct = theStruct;
                        
                        % Remove the old field from the struct so we can
                        % Add the new version back in.
                        theNewStruct = rmfield(theNewStruct, tagNameStr);
                        
                        
                        % The previous repetitions are missing a field--
                        % add the field to all repetitions.
                        for iStruct = 1:numStructs;
                            
                            % We can only add a field to an individual
                            % (scalar) struct.
                            aNewStruct = theStruct.(tagNameStr)(iStruct);
                            aNewStruct.(fieldName) = [];
                            
                            % Build an array of structs that have the new
                            % field.
                            theNewStruct.(tagNameStr)(iStruct) ...
                                = aNewStruct;
                        end
                        
                        theStruct = theNewStruct;
                    end
                    
                    if ~isfield(parsedTag, fieldName)
                    
                        % The parsed tag is missing a field--add the field
                        % to the parsed tag.
                        parsedTag.(fieldName) = [];
                    end   
                end
                
                % All repetitions must have fields in the same order.
                parsedTag = orderfields(...
                    parsedTag, theStruct.(tagNameStr)(1));
            end
        end
        
        theStruct = setfield(...
            theStruct, tagNameStr, {fieldIndex}, parsedTag);
        
    else
    
        % Add the tag to the structure (use non-cells for singletons).
        theStruct.(tagNameStr) = parsedTag;
    end
end
