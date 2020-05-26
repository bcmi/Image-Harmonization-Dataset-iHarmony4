function str = loadSorted(filename)
% Loads data from a mat file in the same order in which it was saved.
%
%   struct = loadSorted(filename)
%
% If the file was saved with the built-in save function, thus containing no 
% sorting information, this function will simply output a warning.
%
% See also:
%   saveSorted
%
% ----------
% Jean-Francois Lalonde

str = load(filename);

if ~isfield(str, 'varOrdering')
    % No sorting information found. Just output a warning and keep going.
    if length(fieldnames(str)) > 1
        % If there's only one field, don't complain since that won't cause
        % an issue
        warning('loadSorted:nosort', ...
            'No sorting information found in the file. Not sorting outputs');
    end

else
    varOrdering = str.varOrdering;
    str = rmfield(str, 'varOrdering');
    
    str = orderfields(str, varOrdering);
end
