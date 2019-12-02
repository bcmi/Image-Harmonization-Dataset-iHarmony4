function saveSorted(filename, varargin)
% Save data in a mat file, and record the order in which variables are
% saved.
%
%   saveSorted(filename, 'var1', 'var2', ...)
%
% See also:
%   loadSorted
%
% ----------
% Jean-Francois Lalonde

% error checking
assert(all(strncmp(varargin, '-struct', 7)==0), ...
    'saveSorted does not support the ''-struct'' option');
assert(all(strncmp(varargin, '-append', 7)==0), ...
    'saveSorted does not support the ''-append'' option');

% we'll save all the variables, but in addition, we'll also save a cell
% array indicating the order in which they were saved
% the variable will look like: varOrdering = {'var1', 'var2', ...}

% find the index of the variables in varargin (remove the '-vXX');
indVar = ~strncmp(varargin, '-v', 2);

% string only the input _variables_
sortedVarListStr = strrep(sprintf('''%s'' ', varargin{indVar}), ...
    ''' ''', ''',''');

% create the 'varOrdering' variable in the caller's workspace
varOrderingStr = strcat('varOrdering = {', sortedVarListStr, '};');
evalin('caller', varOrderingStr);

% string all the input
varListStr = strrep(sprintf('''%s'' ', varargin{:}), ...
    ''' ''', ''',''');

% save the variables, including varOrdering, in the caller's workspace
varListStr = strcat(varListStr, ',''varOrdering''');
saveStr = sprintf('save(''%s'', %s)', filename, varListStr);
evalin('caller', saveStr);

% clean up
evalin('caller', 'clear(''varOrdering'');');