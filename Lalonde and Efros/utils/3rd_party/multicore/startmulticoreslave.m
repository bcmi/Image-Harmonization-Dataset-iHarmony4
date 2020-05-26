function startmulticoreslave(multicoreDir, settings)
%STARTMULTICORESLAVE  Start multi-core processing slave process.
%   STARTMULTICORESLAVE(DIRNAME) starts a slave process for function
%   STARTMULTICOREMASTER. The given directory DIRNAME is checked for data
%   files including which function to run and which parameters to use.
%
%   STARTMULTICORESLAVE (without input arguments) uses the standard
%   directory <TEMPDIR2>/multicorefiles, where <TEMPDIR2> is the directory
%   returned by function tempdir2.
%
%   STARTMULTICORESLAVE(DIRNAME, SETTINGS) uses the field values in the
%   struct SETTINGS to overwrite the standard settings/parameters as set at
%   the very beginning of this file. Use setting "maxIdleTime" to quit the
%   slave Matlab process after a given time in seconds.
%
%   STARTMULTICORESLAVE('', ...) uses the standard directory as mentioned
%   above.
%
%		<a href="multicore.html">multicore.html</a>  <a href="http://www.mathworks.com/matlabcentral/fileexchange/13775">File Exchange</a>  <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=GPUZTN4K63NRY">Donate via PayPal</a>
%
%		Markus Buehren
%		Last modified 18.09.2011
%
%   See also STARTMULTICOREMASTER.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Default settings/parameters. 
% Note: Use second input argument to overwrite these settings.

% Set initial and maximum time to wait before checking again after no slave
% file was found. This pause time prevents "busy waiting".
settingsDefault.startWaitTime = 0.1; % in seconds
settingsDefault.maxWaitTime   = 5.0; % in seconds

% If there are no slave files found for more than this time, the current
% Matlab process will be shut down (thanks Richard!).
settingsDefault.maxIdleTime = inf; % in seconds

% set time after which to notify the user if there are no slave files found
settingsDefault.firstWarnTime = 10; % in seconds

% set first and maximum time after which to repeat the message about
% absence of slave files
settingsDefault.startWarnTime = 10 * 60;   % in seconds
settingsDefault.maxWarnTime   = 24 * 3600; % in seconds

% Activate/deactivate debug messages and additional warnings. Note: These
% options are for development, other settings are overwritten below if
% debugMode is activated!
settingsDefault.debugMode    = 0;
settingsDefault.showWarnings = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% combine default and user-provided settings/parameters
if ~exist('settings', 'var')
  % use default settings
  settings = settingsDefault;
else
  settings = combineSettings(settings, settingsDefault);
end

% settings in debug mode
if settings.debugMode
  settings.showWarnings  = 1;
  settings.firstWarnTime = 10;
  settings.startWarnTime = 10;
  settings.maxWarnTime   = 60;
  settings.maxWaitTime   = 1;
end

% get slave file directory name
if ~exist('multicoreDir', 'var') || isempty(multicoreDir)
  multicoreDir = fullfile(tempdir2, 'multicorefiles');
end
if ~exist(multicoreDir, 'dir')
  try
    mkdir(multicoreDir);
  catch
    error('Unable to create slave file directory %s.', multicoreDir);
  end
end

% initialize variables
lastEvalEndClock = clock;
lastWarnClock    = clock;
firstRun         = true;
curWarnTime      = settings.firstWarnTime;
curWaitTime      = settings.startWaitTime;

persistent lastSessionDateStr

while 1
  parameterFileList = findfiles(multicoreDir, 'parameters_*.mat', 'nonrecursive');

  % Buehren 29.07.2012: Randomly select a parameter file. This minimizes the
  % numbers of collisions (different Matlab sessions trying to access the same
  % parameter file) when a large number of slave sessions is used.
  parameterFileName = '';
  fileIndex = randperm(length(parameterFileList));
  for fileNr = 1:length(fileIndex)
    if isempty(strfind(parameterFileList{fileIndex(fileNr)}, 'semaphore'))
      parameterFileName = parameterFileList{fileIndex(fileNr)};
      break % leave the for-loop
    end
  end

  if ~isempty(parameterFileName)
    if settings.debugMode
      % get parameter file number for debug messages
      fileNr = str2double(regexptokens(parameterFileName,'parameters_\d+_(\d+)\.mat'));
      fprintf('****** Slave is checking file nr %d *******\n', fileNr);
    end

    % load and delete last parameter file
    sem = setfilesemaphore(parameterFileName);
    loadSuccessful = true;
    if existfile(parameterFileName)
      % try to load the parameters
      lastwarn('');
      lasterror('reset');
      try
        load(parameterFileName, 'functionHandles', 'parameters'); %% file access %%
      catch
        loadSuccessful = false;
        if settings.showWarnings
          fprintf('Warning: Unable to load parameter file %s.\n', parameterFileName);
          lastMsg = lastwarn;
          if ~isempty(lastMsg)
            fprintf('Warning message issued when trying to load:\n%s\n', lastMsg);
          end
          displayerrorstruct;
        end
      end

      % check if variables to load are existing
      if loadSuccessful && (~exist('functionHandles', 'var') || ~exist('parameters', 'var'))
        loadSuccessful = false;
        if settings.showWarnings
          disp(textwrap2(sprintf(['Warning: Either variable ''%s'' or ''%s''', ...
            'or ''%s'' not existing after loading file %s.'], ...
            'functionHandles', 'parameters', parameterFileName)));
        end
      end

      if settings.debugMode
        if loadSuccessful
          fprintf('Successfully loaded parameter file nr %d.\n', fileNr);
        else
          fprintf('Problems loading parameter file nr %d.\n', fileNr);
        end
      end

      % remove parameter file
      deleteSuccessful = mbdelete(parameterFileName, settings.showWarnings); %% file access %%
      if ~deleteSuccessful
        % If deletion is not successful it can happen that other slaves or
        % the master also use these parameters. To avoid this, ignore the
        % loaded parameters
        loadSuccessful = false;
        if settings.debugMode
          fprintf('Problems deleting parameter file nr %d. It will be ignored.\n', fileNr);
        end
      end
    else
      loadSuccessful = false;
      if settings.debugMode
        disp('No parameter files found.');
      end
    end

    % remove semaphore and continue if loading was not successful
    if ~loadSuccessful
      removefilesemaphore(sem);
      continue
    end

    % Generate a temporary file which shows when the slave started working.
    % Using this file, the master can decide if the job timed out.
    % Still using the semaphore of the parameter file above.
    workingFile = strrep(parameterFileName, 'parameters', 'working');
    generateemptyfile(workingFile);
    if settings.debugMode
      fprintf('Working file nr %d generated.\n', fileNr);
    end

    % remove semaphore file
    removefilesemaphore(sem);

    % show progress info
    if firstRun
      fprintf('First function evaluation (%s)\n', datestr(clock, 'mmm dd, HH:MM'));
      firstRun = false;
    elseif etime(clock, lastEvalEndClock) > 60
      fprintf('First function evaluation after %s (%s)\n', ...
        formattime(etime(clock, lastEvalEndClock)), datestr(clock, 'mmm dd, HH:MM'));
    end

    %%%%%%%%%%%%%%%%%%%%%
    % evaluate function %
    %%%%%%%%%%%%%%%%%%%%%
    if settings.debugMode
      fprintf('Slave evaluates job nr %d.\n', fileNr);
      t0 = mbtime;
    end

    % Check if date string in parameter file name has changed. If yes, call
    % "clear functions" to ensure that the latest file versions are used,
    % no older versions in Matlab's memory.
    sessionDateStr = regexptokens(parameterFileName, 'parameters_(\d+)_\d+\.mat');
    if ~strcmp(sessionDateStr, lastSessionDateStr)
      clear functions

      if settings.debugMode
        disp('New multicore session detected, "clear functions" called.');
      end
    end
    lastSessionDateStr = sessionDateStr;

    result = cell(size(parameters)); %#ok
    for k=1:numel(parameters)
      if iscell(parameters{k})
        result{k} = feval(getFunctionHandleSlave(functionHandles, k), parameters{k}{:});
      else
        result{k} = feval(getFunctionHandleSlave(functionHandles, k), parameters{k});
      end
    end
    if settings.debugMode
      fprintf('Slave finished job nr %d in %.2f seconds.\n', fileNr, mbtime - t0);
    end

    % Save result. Use file semaphore of the parameter file to reduce the
    % overhead.
    sem = setfilesemaphore(parameterFileName);
    resultFileName = strrep(parameterFileName, 'parameters', 'result');
    try
      save(resultFileName, 'result'); %% file access %%
      if settings.debugMode
        fprintf('Result file nr %d generated.\n', fileNr);
      end
    catch
      if settings.showWarnings
        fprintf('Warning: Unable to save file %s.\n', resultFileName);
        displayerrorstruct;
      end
    end

    % remove working file
    mbdelete(workingFile, settings.showWarnings); %% file access %%
    if settings.debugMode
      fprintf('Working file nr %d deleted.\n', fileNr);
    end

    % remove parameter file (might have been re-generated again by master)
    mbdelete(parameterFileName, settings.showWarnings); %% file access %%
    if settings.debugMode
      fprintf('Parameter file nr %d deleted.\n', fileNr);
    end

    % remove semaphore
    removefilesemaphore(sem);

    % save time
    lastEvalEndClock = clock;
    curWarnTime = settings.startWarnTime;
    curWaitTime = settings.startWaitTime;

    % remove variables before next run
    clear result functionHandle parameters

  else
    % display message or exit if idle for long time
    timeSinceLastEvaluation = etime(clock, lastEvalEndClock);

    % exit slave process if idle for a long time
    if timeSinceLastEvaluation > settings.maxIdleTime
      fprintf('No slave files found during last %s (%s).\n', ...
        formattime(timeSinceLastEvaluation), datestr(clock, 'mmm dd, HH:MM'));
      disp('Exiting MATLAB in ten seconds.');
      pause(10);
      quit force;
    end

    if min(timeSinceLastEvaluation, etime(clock, lastWarnClock)) > curWarnTime
      if timeSinceLastEvaluation >= 10*60
        % round to minutes
        timeSinceLastEvaluation = 60 * round(timeSinceLastEvaluation / 60);
      end
      disp(sprintf('Warning: No slave files found during last %s (%s).', ...
        formattime(timeSinceLastEvaluation), datestr(clock, 'mmm dd, HH:MM')));
      lastWarnClock = clock;
      if firstRun
        curWarnTime = settings.startWarnTime;
      else
        curWarnTime = min(curWarnTime * 2, settings.maxWarnTime);
      end
      curWaitTime = min(curWaitTime + 0.1, settings.maxWaitTime);
    end

    % wait before next check
    pause(curWaitTime);

  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function timeString = formattime(time, mode)
%FORMATTIME  Return formatted time string.
%  STR = FORMATTIME(TIME) returns a formatted time string for the given
%  time difference TIME in seconds, i.e. '1 hour and 5 minutes' for TIME =
%  3900.
%
%  FORMATTIME(TIME, MODE) uses the specified display mode ('long' or
%  'short'). Default is long display.
%
%  Example:
%  str = formattime(142, 'long');
%
%  FORMATTIME (without input arguments) shows further examples.
%
%  Markus Buehren
%  Last modified 21.04.2008
%
%  See also ETIME.

if nargin == 0
  disp(sprintf('\nExamples for strings returned by function %s.m:', mfilename));
  time = [0 1e-4 0.1 1 1.1 2 60 61 62 120 121 122 3600 3660 3720 7200 7260 7320 ...
    3600*24 3600*25 3600*26 3600*48 3600*49 3600*50];
  for k=1:length(time)
    disp(sprintf('time = %6g, timeString = ''%s''', time(k), formattime(time(k))));
  end
  if nargout > 0
    timeString = '';
  end
  return
end

if ~exist('mode', 'var')
  mode = 'long';
end

if time < 0
  disp('Warning: Time must be greater or equal zero.');
  timeString = '';
elseif time >= 3600*24
  days = floor(time / (3600*24));
  if days > 1
    dayString = 'days';
  else
    dayString = 'day';
  end
  hours = floor(mod(time, 3600*24) / 3600);
  if hours == 0
    timeString = sprintf('%d %s', days, dayString);
  else
    if hours > 1
      hourString = 'hours';
    else
      hourString = 'hour';
    end
    timeString = sprintf('%d %s and %d %s', days, dayString, hours, hourString);
  end

elseif time >= 3600
  hours = floor(mod(time, 3600*24) / 3600);
  if hours > 1
    hourString = 'hours';
  else
    hourString = 'hour';
  end
  minutes = floor(mod(time, 3600) / 60);
  if minutes == 0
    timeString = sprintf('%d %s', hours, hourString);
  else
    if minutes > 1
      minuteString = 'minutes';
    else
      minuteString = 'minute';
    end
    timeString = sprintf('%d %s and %d %s', hours, hourString, minutes, minuteString);
  end

elseif time >= 60
  minutes = floor(time / 60);
  if minutes > 1
    minuteString = 'minutes';
  else
    minuteString = 'minute';
  end
  seconds = floor(mod(time, 60));
  if seconds == 0
    timeString = sprintf('%d %s', minutes, minuteString);
  else
    if seconds > 1
      secondString = 'seconds';
    else
      secondString = 'second';
    end
    timeString = sprintf('%d %s and %d %s', minutes, minuteString, seconds, secondString);
  end

else
  if time > 10
    seconds = floor(time);
  else
    seconds = floor(time * 100) / 100;
  end
  if seconds > 0
    if seconds ~= 1
      timeString = sprintf('%.4g seconds', seconds);
    else
      timeString = '1 second';
    end
  else
    timeString = sprintf('%.4g seconds', time);
  end
end

switch mode
  case 'long'
    % do nothing
  case 'short'
    timeString = strrep(timeString, ' and ', ' ');
    timeString = strrep(timeString, ' days', 'd');
    timeString = strrep(timeString, ' day', 'd');
    timeString = strrep(timeString, ' hours', 'h');
    timeString = strrep(timeString, ' hour', 'h');
    timeString = strrep(timeString, ' minutes', 'm');
    timeString = strrep(timeString, ' minute', 'm');
    timeString = strrep(timeString, ' seconds', 's');
    timeString = strrep(timeString, ' second', 's');
  otherwise
    error('Mode ''%s'' unknown in function %s.', mode, mfilename);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fHandles = getFunctionHandleSlave(functionHandleCell, index)

if isa(functionHandleCell, 'function_handle')
  % return function handle as it is
  fHandles = functionHandleCell;
elseif iscell(functionHandleCell)
  % return function handle
  fHandles = functionHandleCell{index};
else
  error('Input type unknown.');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function settings = combineSettings(settings, settingsDefault)

% get settings
if ~isstruct(settings)
  error('Input argument "settings" must be a struct.');
else
  % check if there are unknown field names in struct settings
  fieldNames = fieldnames(settings);
  for k=1:length(fieldNames)
    if ~isfield(settingsDefault, fieldNames{k})
      error('Setting "%s" unknown.', fieldNames{k});
    end
  end

  % set default values where fields are missing in struct settings
  fieldNames = fieldnames(settingsDefault);
  for k=1:length(fieldNames)
    if ~isfield(settings, fieldNames{k})
      settings.(fieldNames{k}) = settingsDefault.(fieldNames{k});
    end
  end
end
