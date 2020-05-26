function [loadSuccessful, varargout] = mbload(fileName, varNameCell, ...
  showWarnings, throwError)
%MBLOAD  Load variables from file and check possible warnings/errors.
%   [SUCCESS, VAR1, VAR2, ...] = MBLOAD(FILE) will check if file FILE is
%   existing, try to load it and check if loading caused an error or
%   warning afterwards. If loading was successful, SUCCESS = 1 is returned,
%   followed by the loaded variables as a structure.
%
%   [SUCCESS, VAR1, VAR2, ...] = MBLOAD(FILE, VARNAMECELL) will only load
%   and return the variables with the names given in the cell array
%   VARNAMECELL.
%
%   [SUCCESS, VAR1, VAR2, ...] = MBLOAD(FILE, VARNAMECELL, SHOWWARNINGS,
%   THROWERROR) with THROWERROR evaluating to TRUE will cause MBLOAD to
%   throw an error if Matlab would have given a warning. With SHOWWARNING
%   evaluating to false, MBLOAD will not display a warning. Default values
%   are THROWERROR = FALSE and SHOWWARNING = TRUE. To load all variables
%   contained in the file, set VARNAMECELL = {}.
%
%   If more variables are requested in the list of output arguments than
%   are loaded from the file, the additional outputs are set to the empty
%   matrix.
%
%   Markus Buehren
%   Last modified 07.04.2009
%
%   See also LOAD, EXISTFILE, WARNING, LASTWARN.

showErrors = 1;

if exist('varNameCell', 'var')
  if ~iscell(varNameCell)
    error('Input argument VARNAMECELL must be a cell array.');
  end
else
  varNameCell = {};
end
if ~exist('showWarnings', 'var')
  showWarnings = 1;
end
if ~exist('throwError', 'var')
  throwError = 0;
end

% reset warnings and errors
lastwarn('');
lasterror('reset');

% turn off variable not found warnings
warnID = 'MATLAB:load:variableNotFound';
warnState = warning('query', warnID);
warning('off', warnID);

if existfile(fileName)
  % try to load the file
  try
    loadedStruct = load(fileName, varNameCell{:}); %% file access %%
    loadSuccessful = true;
  catch
    if throwError
      error('Error: Unable to load file %s.', fileName);
    end
    loadSuccessful = false;
    if showWarnings
      disp(sprintf('Warning: Unable to load file %s.', fileName));
      lastMsg = lastwarn;
      if ~isempty(lastMsg)
        disp(sprintf('Warning message issued when trying to load:\n%s', lastMsg));
      end
      if showErrors
        displayerrorstruct;
      end
    end
  end

  % check if variables to load are existing
  if loadSuccessful && ~isempty(varNameCell)
    for k=1:length(varNameCell)
      if ~isfield(loadedStruct, varNameCell{k})
        loadSuccessful = false;
        if showWarnings || throwError
          disp(sprintf('Warning: Variable ''%s'' not existing after loading file %s.', ...
            varNameCell{k}, fileName));
        end
      end
    end
    
    if ~loadSuccessful && throwError
      error('Loading file %s not successful.', fileName);
    end
  end
else
  % file not existing
  if throwError
    error('Error: File %s not existing.', fileName);
  elseif showWarnings
    disp(sprintf('Warning: File %s not existing.', fileName));

    % check if warning has been suppressed
      lastMsg = lastwarn;
      if ~isempty(lastMsg)
        disp(sprintf('Warning message issued when trying to load:\n%s', lastMsg));
      end
    if showErrors
      displayerrorstruct;
    end
  end
  loadSuccessful = false;
end

if loadSuccessful
  if ~isempty(varNameCell)
    % requested variable names are given
    if nargout > length(varNameCell) + 1
      if throwError
        error('More output variables requested than loaded.');
      elseif showWarnings
        disp('Warning: More output variables requested than loaded.');
      end
    end

    % copy to output argument list
    for k=1:(nargout-1)
      if k <= length(varNameCell) && isfield(loadedStruct, varNameCell{k})
        varargout{k} = loadedStruct.(varNameCell{k});
      else
        varargout{k} = [];
      end
    end
  else
    % no variable names given, return loaded struct
    varargout = {loadedStruct};
    if nargout > 2
      if throwError
        error('Too many output arguments.');
      elseif showWarnings
        disp('Warning: Too many output arguments.');
      end
      for k=2:(nargout-1)
        varargout{k} = [];
      end
    end
  end
else
  % loading was not successful (warning/error messages have been issued
  % before)
  for k=1:(nargout-1)
    varargout{k} = [];
  end
end

% reset warnings
warning(warnState);