function [idx] = CellStrFind(strs, query)
if iscell(query)
    nQuery = numel(query);
    idx = cell(nQuery,1);
    for n = 1 : nQuery
        idx{n} = CellStrFind(strs, query{n});
    end
    idx = cat(2, idx{:});
    if ~isempty(idx)
        idx = unique(idx);
    end
else
    idx_list = strfind(strs, query);
    idx = find(cellfun(@isempty, idx_list) == 0);
end
end

