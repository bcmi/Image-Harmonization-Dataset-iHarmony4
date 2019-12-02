function [paths] = AddPaths(fold, lists)
paths = cellfun(@(S) fullfile(fold, S), lists, 'Uniform', 0); 
end

