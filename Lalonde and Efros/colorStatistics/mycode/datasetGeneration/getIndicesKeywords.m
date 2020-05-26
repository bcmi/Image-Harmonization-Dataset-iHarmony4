%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [topKeywords, topIndices] = getIndicesKeywords(objectDb)
%   Get the keywords and associated indices from a database
% 
% Input parameters:
%   - objectDb: pre-loaded object database
%
% Output parameters:
%   - topKeywords: top-level keywords available in the database
%   - topIndices: indices that map the top-level keywords to instances in the database
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [topKeywords, topIndices] = getIndicesKeywords(objectDb, minNbObjects) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

objectNames = arrayfun(@(x)x.document.object.name, objectDb, 'UniformOutput', 0);
% make lower-case and remove spaces
objectNames = lower(objectNames);
objectNames = strrep(objectNames, ' ', '');

% These will be the top keywords
groupedKeywords = cellfun(@(x) filterKeyword(x), objectNames, 'UniformOutput', 0);

topKeywords = unique(groupedKeywords);
topIndices = arrayfun(@(x)find(strcmp(groupedKeywords, x)), topKeywords, 'UniformOutput', 0);

% Only keep the keywords which have enough instances
% n = arrayfun(@(x) nnz(strcmp(filteredKeywords, x)), filteredKeywordsType, 'UniformOutput', 1);
n = cellfun(@(x) length(x), topIndices, 'UniformOutput', 1);
indOk = find(n >= minNbObjects);

% Remove the first one, which contains the bad objects (cropped, parts, etc.)
indOk = indOk(2:end);

topKeywords = topKeywords(indOk);
topIndices = topIndices(indOk);


