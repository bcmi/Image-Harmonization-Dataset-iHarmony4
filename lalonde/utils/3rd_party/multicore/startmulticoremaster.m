function resultCell = startmulticoremaster(functionHandleCell, parameterCell, settings)
%STARTMULTICOREMASTER  Start multicore master process.
%   RESULTCELL = STARTMULTICOREMASTER(FHANDLE, PARAMETERCELL)
%   starts a multi-core processing master process. The function specified
%   by the given function handle is evaluated with the parameters saved in
%   each cell of PARAMETERCELL. Each cell may include parameters in any
%   form or another cell array which is expanded to an argument list using
%   the {:} notation to pass multiple input arguments. The outputs of the
%   function are returned in cell array RESULTCELL of the same size as
%   PARAMETERCELL. Only the first output argument of the function is
%   returned. If you need to get multiple outputs, write a small adapter
%   that puts the outputs of your function into a single cell array.
%
%   To make use of multiple cores/machines, function STARTMULTICOREMASTER
%   saves files with the function handle and the parameters to a temporary
%   directory (default: <TEMPDIR2>/multicorefiles, where <TEMPDIR2> is the
%   directory returned by function TEMPDIR2). These files are loaded by
%   function STARTMULTICORESLAVE running in other Matlab processes which
%   have access to the temporary directory. The slave processes evaluate
%   the given function with the saved parameters and save the result in
%   another file. The results are later collected by the master process.
%
%   Note that you can make use of multiple cores on a single machine or on
%   different machines with a commonly accessible directory/network share
%   or a combination of both.
%
%   RESULTCELL = STARTMULTICOREMASTER(FHANDLE, PARAMETERCELL, SETTINGS)
%   The additional input structure SETTINGS may contain any of the
%   following fields:
%
%   settings.multicoreDir:
%     Directory for temporary files (standard directory is used if empty)
%   settings.nrOfEvalsAtOnce:
%     Number of function evaluations gathered to a single job.
%   settings.maxEvalTimeSingle:
%     Timeout for a single function evaluation. Choose this parameter
%     appropriately to get optimum performance.
%   settings.masterIsWorker:
%     If true, master process acts as worker and coordinator, if false the
%     master acts only as coordinator.
%   settings.useWaitbar:
%     If true, a waitbar is opened to inform about the overall progress.
%
%   Please refer to the heavily commented demo function MULTICOREDEMO for
%   details and explanations of the settings.
%
%   RESULTCELL = STARTMULTICOREMASTER(FHANDLECELL, PARAMETERCELL, ...),
%   with a cell array FHANDLECELL including function handles, allows to
%   evaluate different functions.
%
%   Example: If you have your parameters saved in parameter cell
%   PARAMETERCELL, the for-loop
%
%   	for k=1:numel(PARAMETERCELL)
%   		RESULTCELL{k} = FHANDLE(PARAMETERCELL{k});
%   	end
%
%   which you would run in a single process can be run in parallel on
%   different cores/machines using STARTMULTICOREMASTER and
%   STARTMULTICORESLAVE. Run
%
%   	RESULTCELL = STARTMULTICOREMASTER(FHANDLE, PARAMETERCELL, DIRNAME)
%
%   in one Matlab process and
%
%   	STARTMULTICORESLAVE(DIRNAME)
%
%   in one or more other Matlab processes.
%
%		<a href="multicore.html">multicore.html</a>  <a href="http://www.mathworks.com/matlabcentral/fileexchange/13775">File Exchange</a>  <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=GPUZTN4K63NRY">Donate via PayPal</a>
%
%		Markus Buehren
%		Last modified 04.07.2011
%
%   See also STARTMULTICORESLAVE, FUNCTION_HANDLE.

debugMode    = 0;
showWarnings = 0;

% parameters
startPauseTime = 0.1;
maxPauseTime   = 2;

% default settings/parameters
settingsDefault.multicoreDir        = '';
settingsDefault.nrOfEvalsAtOnce     = 1;
settingsDefault.maxEvalTimeSingle   = 60;
settingsDefault.masterIsWorker      = 1;
settingsDefault.useWaitbar          = 0;
settingsDefault.postProcessHandle   = '';
settingsDefault.postProcessUserData = {};

if debugMode
  fprintf('*********** Start of function %s **********\n', mfilename);
  startTime    = mbtime;
  showWarnings = 1;
  setTime      = 0;
  removeTime   = 0;
end

% check inputs
error(nargchk(2, 3, nargin, 'struct'))

% check function handle cell
if ~isa(functionHandleCell, 'function_handle')
  if ~iscell(functionHandleCell)
    error('First input argument must be a function handle or a cell array of function handles.');
  elseif ~all(size(functionHandleCell) == [1 1]) && ...
      ~all(size(functionHandleCell) == size(parameterCell))
    error(['Input cell array functionHandleCell must be of ', ...
      'size 1x1 or the same size as the parameterCell.']);
  end
end

% check parameter cell
if ~iscell(parameterCell)
  error('Second input argument must be a cell array.');
end

% get settings
if ~exist('settings', 'var')
  % use default settings
  settings = settingsDefault;
else
  settings = combineSettings(settings, settingsDefault);
end

% initialize waitbar
if settings.useWaitbar
  clear multicoreWaitbar
  multicoreWaitbar('init0', @multicoreCancel1);
end

% check number of evaluations at once
nrOfEvals = numel(parameterCell);
nrOfEvalsAtOnce = settings.nrOfEvalsAtOnce;
if nrOfEvalsAtOnce > nrOfEvals
  nrOfEvalsAtOnce = nrOfEvals;
elseif nrOfEvalsAtOnce < 1
  error('Parameter nrOfEvalsAtOnce must be greater or equal one.');
end
nrOfEvalsAtOnce = round(nrOfEvalsAtOnce);

% check slave file directory
if isempty(settings.multicoreDir)
  % create default slave file directory if not existing
  multicoreDir = fullfile(tempdir2, 'multicorefiles');
  if ~exist(multicoreDir, 'dir')
    try
      mkdir(multicoreDir);
    catch
      error('Unable to create slave file directory %s.', multicoreDir);
    end
  end
else
  multicoreDir = settings.multicoreDir;
  if ~exist(multicoreDir, 'dir')
    error('Slave file directory %s not existing.', multicoreDir);
  end
end

% check maxEvalTimeSingle
maxEvalTimeSingle = settings.maxEvalTimeSingle;
if maxEvalTimeSingle < 0
  error('Parameter maxEvalTimeSingle must be greater or equal zero.');
end

% compute the maximum waiting time for a complete job
maxMasterWaitTime = maxEvalTimeSingle * nrOfEvalsAtOnce;

% compute number of files/jobs
nrOfFiles = ceil(nrOfEvals / nrOfEvalsAtOnce);
if debugMode
  fprintf('nrOfFiles = %d\n', nrOfFiles);
end

% Initialize structure for postprocessing function
if ~isempty(settings.postProcessHandle)
  postProcStruct.state               = 'initialization';
  postProcStruct.nrOfFiles           = nrOfFiles;
  postProcStruct.functionHandleCell  = functionHandleCell;
  postProcStruct.parameterCell       = parameterCell;
  postProcStruct.userData            = settings.postProcessUserData;
  feval(settings.postProcessHandle, postProcStruct);
end

% remove all existing temporary multicore files
existingMulticoreFiles = [...
  findfiles(multicoreDir, 'parameters_*.mat', 'nonrecursive'), ...
  findfiles(multicoreDir, 'working_*.mat',    'nonrecursive'), ...
  findfiles(multicoreDir, 'result_*.mat',     'nonrecursive')];
deletewithsemaphores(existingMulticoreFiles);

% build parameter file name (including the date is important because slave
% processes might still be working with old parameters)
dateStr = sprintf('%04d%02d%02d%02d%02d%02d', round(clock));
parameterFileNameTemplate = fullfile(multicoreDir, sprintf('parameters_%s_XX.mat', dateStr));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate parameter files %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize waitbar again
multicoreWaitbar('init1', nrOfFiles);

% save parameter files with all parameter sets
multicoreCancelled = false;
for lastFileNrMaster = nrOfFiles:-1:1
  curFileNr = lastFileNrMaster; % for simpler copy&paste
  parameterFileName = strrep(parameterFileNameTemplate, 'XX', sprintf('%04d', curFileNr));
  parIndex = ((curFileNr-1)*nrOfEvalsAtOnce+1) : min(curFileNr*nrOfEvalsAtOnce, nrOfEvals);
  functionHandles = getFunctionHandles(functionHandleCell, parIndex); %#ok
  parameters      = parameterCell(parIndex); %#ok

  if debugMode, t1 = mbtime; end
  sem = setfilesemaphore(parameterFileName);
  if debugMode, setTime = setTime + mbtime - t1; end

  try
    save(parameterFileName, 'functionHandles', 'parameters'); %% file access %%
    if debugMode
      fprintf('Parameter file nr %d generated.\n', curFileNr);
    end
  catch
    if showWarnings
      disp(textwrap2(sprintf('Warning: Unable to save file %s.', parameterFileName)));
      displayerrorstruct;
    end
  end

  if debugMode, t1 = mbtime; end
  removefilesemaphore(sem);
  if debugMode, removeTime = removeTime + mbtime - t1; end

  if multicoreCancelled
    multicoreCancel2(lastFileNrMaster, nrOfFiles);
    return
  end

  % Update waitbar
  multicoreWaitbar('update1', nrOfFiles, lastFileNrMaster);

end

resultCell = cell(size(parameterCell));

lastFileNrMaster = 1;         % start working down the list from top to bottom
lastFileNrSlave = nrOfFiles; % check for results from bottom to top
parameterFileFoundTime  = NaN;
parameterFileRegCounter = 0;
nrOfFilesMaster = 0;
nrOfFilesSlaves = 0;

% Initialize waitbar again
multicoreWaitbar('init2');

% Call "clear functions" to ensure that the latest file versions are used,
% no older versions in Matlab's memory.
% JFL edit: do we really need the master to do this?!
% clear functions

firstRun = true;
masterIsWorker = settings.masterIsWorker;
while 1 % this while-loop will be left if all work is done
  if masterIsWorker && ~firstRun
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % work down the file list from top %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if debugMode
      fprintf('********** 1. Working from top to bottom (file nr %d)\n', lastFileNrMaster);
    end
    curFileNr = lastFileNrMaster; % for simpler copy&paste
    parameterFileName = strrep(parameterFileNameTemplate, 'XX', sprintf('%04d', curFileNr));
    resultFileName    = strrep(parameterFileName, 'parameters', 'result' );
    workingFileName   = strrep(parameterFileName, 'parameters', 'working');
    parIndex = ((curFileNr-1)*nrOfEvalsAtOnce+1) : min(curFileNr*nrOfEvalsAtOnce, nrOfEvals);

    if multicoreCancelled
      multicoreCancel2(lastFileNrMaster, lastFileNrSlave);
      return
    end

    if debugMode, t1 = mbtime; end
    sem = setfilesemaphore(parameterFileName);
    if debugMode, setTime = setTime + mbtime - t1; end

    parameterFileExisting = existfile(parameterFileName);
    if parameterFileExisting
      % If the parameter file is existing, no other process has started
      % working on that job --> Remove parameter file, so that no slave
      % process can load it. The master will do the current job.
      mbdelete(parameterFileName, showWarnings);
      if debugMode
        fprintf('Parameter file nr %d deleted by master.\n', curFileNr);
      end
    end

    % check if the current parameter set was evaluated before by a slave process
    resultLoaded = false;
    if parameterFileExisting
      % If the master has taken the parameter file, there is no need to check
      % for a result. Semaphore will be removed below.
      if debugMode
        fprintf('Not checking for result because parameter file nr %d was existing.\n', curFileNr);
      end

    else
      % Another process has taken the parameter file. This branch is
      % entered if master and slave "meet in the middle", i.e. if a slave
      % has taken the parameter file of the job the master would have done
      % next. In this case, the master will wait until the job was finished
      % by the slave process or until the job has timed out.
      curPauseTime = startPauseTime;
      firstRun = true;
      while 1 % this while-loop will be left if result was loaded or job timed out
        if firstRun
          % use the semaphore generated above
          firstRun = false;
        else
          % set semaphore
          if debugMode, t1 = mbtime; end
          sem = setfilesemaphore(parameterFileName);
          if debugMode, setTime = setTime + mbtime - t1; end
        end

        % Check if the result is available. The semaphore file of the
        % parameter file is used for the following file accesses of the
        % result file.
        if existfile(resultFileName)
          [result, resultLoaded] = loadResultFile(resultFileName, showWarnings);
          if resultLoaded && debugMode
            fprintf('Result file nr %d loaded.\n', curFileNr);
          end
        else
          resultLoaded = false;
          if debugMode
            fprintf('Result file nr %d was not found.\n', curFileNr);
          end
        end

        if resultLoaded
          % Save result
          resultCell(parIndex) = result;
          nrOfFilesSlaves = nrOfFilesSlaves + 1;

          % Update waitbar
          multicoreWaitbar('update2', nrOfFiles, nrOfFilesMaster, nrOfFilesSlaves);

          % Leave while-loop immediately after result was loaded. Semaphore
          % will be removed below.
          break
        end

        % Check if the processing time (current time minus time stamp of
        % working file) exceeds the maximum wait time. Still using the
        % semaphore of the parameter file from above.
        if existfile(workingFileName)
          if debugMode
            fprintf('Master found working file nr %d.\n', curFileNr);
          end

          % Check if the job timed out by getting the time when the slave
          % started working on that file. If the job has timed out, the
          % master will do the job.
          jobTimedOut = mbtime - getfiledate(workingFileName) * 86400 > maxMasterWaitTime;
        else
          % No working file has been found. The loop is immediately left
          % and the master will do the job.
          if showWarnings
            fprintf('Warning: Working file %s not found.\n', workingFileName);
          end
          jobTimedOut = true;
        end

        if jobTimedOut
          if debugMode
            fprintf('Job nr %d has timed out.\n', curFileNr);
          end
          % As the slave process seems to be dead or too slow, the master
          % will do the job itself (semaphore will be removed below).
          break
        else
          if debugMode
            fprintf('Job nr %d has NOT timed out.\n', curFileNr);
          end
        end

        % If the job did not time out, remove semaphore and wait a moment
        % before checking again
        if debugMode, t1 = mbtime; end
        removefilesemaphore(sem);
        if debugMode, removeTime = removeTime + mbtime - t1; end

        if debugMode
          fprintf('Waiting for result (file nr %d).\n', curFileNr);
        end

        pause(curPauseTime);
        curPauseTime = min(maxPauseTime, curPauseTime + startPauseTime);
      end % while 1
    end % if parameterFileExisting

    % remove semaphore
    if debugMode, t1 = mbtime; end
    removefilesemaphore(sem);
    if debugMode, removeTime = removeTime + mbtime - t1; end

    if multicoreCancelled
      multicoreCancel2(lastFileNrMaster, lastFileNrSlave);
      return
    end

    % evaluate function if the result could not be loaded
    if ~resultLoaded
      if debugMode
        fprintf('Master evaluates job nr %d.\n', curFileNr);
        t0 = mbtime;
      end
      for k = parIndex
        if debugMode
          %fprintf(' %d,', k);
        end
        if iscell(parameterCell{k})
          resultCell{k} = feval(getFunctionHandles(functionHandleCell, k), parameterCell{k}{:});
        else
          resultCell{k} = feval(getFunctionHandles(functionHandleCell, k), parameterCell{k});
        end

        if multicoreCancelled
          multicoreCancel2(lastFileNrMaster, lastFileNrSlave);
          return
        end
      end
      nrOfFilesMaster = nrOfFilesMaster + 1;
      
      % Run postprocessing function
      if ~isempty(settings.postProcessHandle)
        postProcStruct.state               = 'after master evaluation'; % no copy & paste here!!
        postProcStruct.lastFileNrReady     = lastFileNrMaster;          % no copy & paste here!!
        postProcStruct.lastFileNrMaster    = lastFileNrMaster;
        postProcStruct.lastFileNrSlave     = lastFileNrSlave;
        postProcStruct.nrOfFilesMaster     = nrOfFilesMaster;
        postProcStruct.nrOfFilesSlaves     = nrOfFilesSlaves;
        postProcStruct.resultCell          = resultCell;
        postProcStruct.parIndex            = parIndex;
        feval(settings.postProcessHandle, postProcStruct);
      end

      % Update waitbar
      multicoreWaitbar('update2', nrOfFiles, nrOfFilesMaster, nrOfFilesSlaves);

      if debugMode
        fprintf('Master finished job nr %d in %.2f seconds.\n', curFileNr, mbtime - t0);
      end
    end

    % move to next file
    lastFileNrMaster = lastFileNrMaster + 1;
    if debugMode
      fprintf('Moving to next file (%d -> %d).\n', curFileNr, curFileNr + 1);
    end

  end % if masterIsWorker

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Check if all work is done %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % (lastFileNrMaster - 1) is the number of the file/job that was last computed/loaded when
  % working down the list from top to bottom.
  % (lastFileNrSlave + 1) is the number of the file/job that was last computed/loaded when
  % checking for results from bottom to top.
  if (lastFileNrMaster - 1) + 1 == (lastFileNrSlave + 1)
    % all results have been collected, leave big while-loop
    if debugMode
      disp('********************************');
      fprintf('All work is done (lastFileNrMaster = %d, lastFileNrSlave = %d).\n', lastFileNrMaster, lastFileNrSlave);
    end
    break
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % work down the file list from bottom to top and collect results %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if debugMode
    fprintf('********** 2. Working from bottom to top (file nr %d)\n', lastFileNrSlave);
  end

  curPauseTime = startPauseTime;
  while 1 % in this while-loop, lastFileNrSlave will be decremented if results are found
    if lastFileNrSlave < 1
      % all work is done
      if debugMode
        disp('********************************');
        fprintf('All work is done (lastFileNrSlave = %d).\n', lastFileNrSlave);
      end
      break
    end

    curFileNr = lastFileNrSlave; % for simpler copy&paste
    parameterFileName = strrep(parameterFileNameTemplate, 'XX', sprintf('%04d', curFileNr));
    resultFileName    = strrep(parameterFileName, 'parameters', 'result' );
    workingFileName   = strrep(parameterFileName, 'parameters', 'working');
    parIndex = ((curFileNr-1)*nrOfEvalsAtOnce+1) : min(curFileNr*nrOfEvalsAtOnce, nrOfEvals);

    if multicoreCancelled
      multicoreCancel2(lastFileNrMaster, lastFileNrSlave);
      return
    end

    % set semaphore (only for the parameter file to reduce overhead)
    if debugMode, t1 = mbtime; end
    sem = setfilesemaphore(parameterFileName);
    if debugMode, setTime = setTime + mbtime - t1; end

    % Check if the result is available (the semaphore file of the
    % parameter file is used for the following file accesses of the
    % result file)
    if existfile(resultFileName)
      [result, resultLoaded] = loadResultFile(resultFileName, showWarnings);
      if resultLoaded && debugMode
        fprintf('Result file nr %d loaded.\n', curFileNr);
      end
    else
      resultLoaded = false;
      if debugMode
        fprintf('Result file nr %d was not found.\n', curFileNr);
      end
    end

    if resultLoaded
      % Result was successfully loaded. Remove semaphore.
      if debugMode, t1 = mbtime; end
      removefilesemaphore(sem);
      if debugMode, removeTime = removeTime + mbtime - t1; end

      % Save result
      resultCell(parIndex) = result;
      nrOfFilesSlaves = nrOfFilesSlaves + 1;

      % Run postprocessing function
      if ~isempty(settings.postProcessHandle)
        postProcStruct.state               = 'after loading result'; % no copy & paste here!!
        postProcStruct.lastFileNrReady     = lastFileNrSlave;        % no copy & paste here!!
        postProcStruct.lastFileNrMaster    = lastFileNrMaster;
        postProcStruct.lastFileNrSlave     = lastFileNrSlave;
        postProcStruct.nrOfFilesMaster     = nrOfFilesMaster;
        postProcStruct.nrOfFilesSlaves     = nrOfFilesSlaves;
        postProcStruct.resultCell          = resultCell;
        postProcStruct.parIndex            = parIndex;
        feval(settings.postProcessHandle, postProcStruct);
      end

      % Update waitbar
      multicoreWaitbar('update2', nrOfFiles, nrOfFilesMaster, nrOfFilesSlaves);

      % Reset variables
      parameterFileFoundTime = NaN;
      curPauseTime = startPauseTime;
      parameterFileRegCounter = 0;

      % Decrement lastFileNrSlave
      lastFileNrSlave = lastFileNrSlave - 1;

      % Check if all work is done
      if (lastFileNrMaster - 1) + 1 == (lastFileNrSlave + 1)
        % all results have been collected
        break
      else
        if debugMode
          fprintf('***** Moving to next file (%d -> %d).\n', curFileNr, curFileNr-1);
        end

        % move to next file
        continue
      end

    else
      % Result was not available.

      % Check if parameter file is existing.
      parameterFileExisting = existfile(parameterFileName);

      % Check if job timed out.
      if parameterFileExisting
        if debugMode
          fprintf('Parameter file nr %d was existing.\n', curFileNr);
        end

        % If the parameter file is existing, no other process has started
        % working on that job yet, which is most of the times normal.
        if ~isnan(parameterFileFoundTime)
          % If parameterFileFoundTime is not NaN, the same parameter file
          % has been found before. Now check if the job has timed out,
          % i.e. no slave process seems to be alive.
          jobTimedOut = mbtime - parameterFileFoundTime > maxMasterWaitTime;
        else
          % Remember the current time to decide later if the job has timed out.
          parameterFileFoundTime = mbtime;
          jobTimedOut = false;
        end
      else
        if debugMode
          fprintf('Parameter file nr %d was NOT existing.\n', curFileNr);
        end

        % Parameter file has been taken by a slave, who should be working
        % on the job.
        if existfile(workingFileName)
          if debugMode
            fprintf('Master found working file nr %d.\n', curFileNr);
          end
          % Check if the job has timed out using the time stamp of the
          % working file.
          jobTimedOut = mbtime - getfiledate(workingFileName) * 86400 > maxMasterWaitTime;
        else
          % Parameter file has been taken but no working file has been
          % generated, which is not normal. The master will generate the
          % parameter file again or do the job.
          if showWarnings
            fprintf('Warning: Working file %s not found.\n', workingFileName);
          end
          jobTimedOut = true;
        end
      end % if parameterFileExisting

      % Do the job or generate parameter file again if job has timed out.
      if jobTimedOut
        if debugMode
          fprintf('Job nr %d has timed out.\n', curFileNr);
        end

        if parameterFileExisting
          % The job timed out and the parameter file was existing, so
          % something seems to be wrong. A possible reason is that no
          % slaves are alive anymore. The master will do the job.

          % Remove parameter file so that no other slave process can load it.
          mbdelete(parameterFileName, showWarnings);
          if debugMode
            fprintf('Parameter file nr %d deleted by master.\n', curFileNr);
          end
        else
          % The job timed out and the parameter file was not existing.
          % A possible reason is that a slave process was killed while
          % working on the current job (if a slave is still working on
          % the job and is just too slow, the parameter maxEvalTimeSingle
          % should be chosen higher). The parameter file is generated
          % again, hoping that another slave will finish the job. If all
          % slaves are dead, the master will later do the job.
          functionHandles = getFunctionHandles(functionHandleCell, parIndex); %#ok
          parameters      = parameterCell(parIndex); %#ok
          try
            save(parameterFileName, 'functionHandles', 'parameters'); %% file access %%
            if debugMode
              fprintf('Parameter file nr %d was generated again (%d. time).\n', ...
                curFileNr, parameterFileRegCounter);
            end
          catch
            if showWarnings
              disp(textwrap2(sprintf('Warning: Unable to save file %s.', parameterFileName)));
              displayerrorstruct;
            end
          end
          parameterFileRegCounter = parameterFileRegCounter + 1;
        end

        % Remove semaphore.
        if debugMode, t1 = mbtime; end
        removefilesemaphore(sem);
        if debugMode, removeTime = removeTime + mbtime - t1; end

        if multicoreCancelled
          multicoreCancel2(lastFileNrMaster, lastFileNrSlave);
          return
        end

        if parameterFileExisting  || parameterFileRegCounter > 2
          % The current job has timed out and the parameter file was not
          % generated again OR the same parameter file has been
          % re-generated several times ==> The master will do the job.
          if debugMode
            fprintf('Master evaluates job nr %d.\n', curFileNr);
            t0 = mbtime;
          end
          for k = parIndex
            if iscell(parameterCell{k})
              resultCell{k} = feval(getFunctionHandles(functionHandleCell, k), parameterCell{k}{:});
            else
              resultCell{k} = feval(getFunctionHandles(functionHandleCell, k), parameterCell{k});
            end

            if multicoreCancelled
              multicoreCancel2(lastFileNrMaster, lastFileNrSlave);
              return
            end

          end
          nrOfFilesMaster = nrOfFilesMaster + 1;

          % Update waitbar
          multicoreWaitbar('update2', nrOfFiles, nrOfFilesMaster, nrOfFilesSlaves);

          if debugMode
            fprintf('Master finished job nr %d in %.2f seconds.\n', curFileNr, mbtime - t0);
          end

          % Result has been computed, move to next file
          lastFileNrSlave = lastFileNrSlave - 1;

          % Reset number of times the current parameter file was generated
          % again
          parameterFileRegCounter = 0;

          if debugMode
            fprintf('Moving to next file (%d -> %d).\n', curFileNr, curFileNr-1);
          end
        else
          % The parameter file has been generated again. The master does
          % not do the job, lastFileNrSlave is not decremented.
        end % if ~parameterFileExisting

        % reset variables
        parameterFileFoundTime = NaN;
        curPauseTime = startPauseTime;
      else
        if debugMode
          fprintf('Job nr %d has NOT timed out.\n', curFileNr);
        end

        % Remove semaphore.
        if debugMode, t1 = mbtime; end
        removefilesemaphore(sem);
        if debugMode, removeTime = removeTime + mbtime - t1; end

        if ~masterIsWorker
          % If the master is only coordinator, wait some time before
          % checking again
          if debugMode
            fprintf('Coordinator is waiting %.2f seconds\n', curPauseTime);
          end
          pause(curPauseTime);
          curPauseTime = min(maxPauseTime, curPauseTime + startPauseTime);
        end
      end % if jobTimedOut

      if masterIsWorker
        % If the master is also a worker, leave the while-loop if the
        % result has not been loaded. Either the job timed out and was done
        % by the master or the job has not been finished yet but is also
        % not timed out, which is normal.
        break
      else
        % If the master is only coordinator, stay in the while-loop.
      end

    end % if resultLoaded
  end % while 1

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Check if all work is done %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % (see comment between the two while-loops)
  if (lastFileNrMaster - 1) + 1 == (lastFileNrSlave + 1)
    % all results have been collected, leave big while-loop
    if debugMode
      disp('********************************');
      fprintf('All work is done (lastFileNrMaster = %d, lastFileNrSlave = %d).\n', lastFileNrMaster, lastFileNrSlave);
    end
    break
  end
  
  firstRun = false;
end % while 1

% Delete waitbar
multicoreWaitbar('delete');

if debugMode
  fprintf('\nSummary:\n--------\n');
  fprintf('%2d jobs at all\n',           nrOfFiles);
  fprintf('%2d jobs done by master\n',   nrOfFilesMaster);
  fprintf('%2d jobs done by slave(s)\n', nrOfFilesSlaves);
  %disp('No jobs done by slave(s). (Note: You need to run function startmulticoreslave.m in another Matlab session?)');
  
  overallTime = mbtime - startTime;
  fprintf('Processing took %.1f seconds.\n', overallTime);
  fprintf('Overhead caused by setting  semaphores: %.1f seconds (%.1f%%).\n', ...
    setTime,    100*setTime    / overallTime);
  fprintf('Overhead caused by removing semaphores: %.1f seconds (%.1f%%).\n', ...
    removeTime, 100*removeTime / overallTime);
  fprintf('\n*********** End of function %s **********\n', mfilename);
end

% Ask user for feedback
%userfeedback('Multicore', mfilename, 50, 30);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Cancel processing by callback %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% I don't like using nested functions, but they are useful for handling
% callbacks.
  function multicoreCancel1
    % This function is called by function cancelCallback if the user
    % pressed the "Cancel" button in the waitbar window.
    fprintf('Function %s cancelled upon user request.\n', mfilename);

    % set variable multicoreCancelled
    multicoreCancelled = true;

  end % function

  function multicoreCancel2(minFileNr, maxFileNr)
    % This function is called from somewhere in the large while-loop if the
    % variable multicoreCancelled is true.

    % Initialize waitbar again
    multicoreWaitbar('init3');

    % Remove all remaining parameter files
    for lastFileNrMasterTmp = minFileNr:maxFileNr
      curFileNr = lastFileNrMasterTmp; % for simpler copy&paste
      parameterFileName = strrep(parameterFileNameTemplate, 'XX', sprintf('%04d', curFileNr));

      if debugMode, t1 = mbtime; end
      sem = setfilesemaphore(parameterFileName);
      if debugMode
        setTime = setTime + mbtime - t1;
        parameterFileExistingTmp = existfile(parameterFileName);
      end

      mbdelete(parameterFileName, showWarnings);
      if debugMode, t1 = mbtime; end
      removefilesemaphore(sem);
      if debugMode, removeTime = removeTime + mbtime - t1; end

      multicoreWaitbar('update3', minFileNr, maxFileNr, lastFileNrMasterTmp);
      if debugMode && parameterFileExistingTmp
        fprintf('Parameter file nr %d deleted.\n', curFileNr);
      end
    end

    % Delete waitbar
    multicoreWaitbar('delete');

    % Set return value to empty cell
    resultCell = {};

  end % function

end % function startmulticoremaster

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [result, resultLoaded] = loadResultFile(resultFileName, showWarnings)

% reset warnings and errors
lastwarn('');
lasterror('reset');

% try to load file
try
  result = []; % (only for M-Lint)
  load(resultFileName, 'result'); %% file access %%
  resultLoaded = true;
catch %#ok
  resultLoaded = false;
  if showWarnings
    fprintf('Warning: Unable to load file %s.\n', resultFileName);
    displayerrorstruct;
  end
end

% display warning (if any)
if showWarnings
  lastMsg = lastwarn;
  if ~isempty(lastMsg)
    fprintf('Warning issued when trying to load file %s:\n%s\n', ...
      resultFileName, lastMsg);
  end
end

% check if variable 'result' is existing
if resultLoaded && ~exist('result', 'var')
  if showWarnings
    fprintf('Warning: Variable ''%s'' not existing after loading file %s.\n', ...
      'result', resultFileName);
  end
  resultLoaded = false;
end

if resultLoaded
  % it seems that loading was successful
  % try to remove result file
  mbdelete(resultFileName, showWarnings); %% file access %%
end

end % function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function multicoreWaitbar(command, varargin)
%MULTICOREWAITBAR  Handle multicore waitbar.

persistent useWaitbar initialized waitbarHandle waitbarMessage fractionReady
persistent clockStart1 clockStart2 clockInit0 clockUpdate multicoreCancelHandle
if isempty(initialized)
  initialized   = 0;
  useWaitbar    = 0;
  fractionReady = 0;
end

switch command
  case 'init0'
    % called at the very beginning

    % save persistent variables
    multicoreCancelHandle = varargin{1};
    useWaitbar = 1;

    % remember time
    clockInit0  = clock;
    clockUpdate = clock;

    % nothing else to do now
    return

  otherwise
    % nothing to do
end

if ~useWaitbar
  return
end

tag = 'Multicore waitbar';
waitbarExisting = ~isempty(waitbarHandle) && ishandle(waitbarHandle);
updateNow = etime(clock, clockUpdate) > 1.0;

switch command
  case 'init1'
    % called before parameter file generation

    % change waitbar message
    nrOfFiles = varargin{1};
    waitbarMessage = sprintf('Generating parameter files.\n0/%d done.\n\n', nrOfFiles);
    fractionReady = 0;

    % remember time
    clockStart1 = clock;
    clockUpdate = clock;

  case 'update1'
    % update during parameter file generation
    if updateNow
      nrOfFiles = varargin{1};
      lastFileNrMaster    = varargin{2};
      nrOfFilesReady = lastFileNrMaster - 1;
      fractionReady = 1 - (nrOfFilesReady / nrOfFiles); % lastFileNrMaster decreases from nrOfFiles to 1
      if fractionReady > 0
        timeLeft = etime(clock, clockStart1) * (1 - fractionReady) / fractionReady;
        waitbarMessage = sprintf('Generating parameter files.\n%d/%d done.\nestimated time left: %s\n', ...
          nrOfFiles - nrOfFilesReady, nrOfFiles, formattime(round(timeLeft), 'short'));
      else
        waitbarMessage = '';
      end
    end

  case 'init2'
    % called before start of big while-loop

    % change waitbar message
    waitbarMessage = sprintf('0.0%% done by master\n0.0%% done by slave(s)\n0.0%% done overall\n');
    fractionReady  = 0;

    % force update, as first function evaluation may take a long time
    updateNow = 1;

    % remember time
    clockStart2 = clock;
    clockUpdate = clock;

  case 'update2'
    % update after function evaluation
    if updateNow
      nrOfFiles       = varargin{1};
      nrOfFilesMaster = varargin{2};
      nrOfFilesSlaves = varargin{3};
      nrOfFilesReady  = nrOfFilesMaster + nrOfFilesSlaves;

      if 1%nrOfFilesReady > 1 % master should have checked for results at least once
        
        fractionReady = nrOfFilesReady / nrOfFiles;

        if nrOfFilesSlaves > 0
          nrOfFilesSlavesTmp = nrOfFilesSlaves + 0.5; % tweak for better estimation
        else
          nrOfFilesSlavesTmp = nrOfFilesSlaves;
        end
        filesPerSecond = ...
          nrOfFilesMaster    / etime(clock, clockStart2) + ...
          nrOfFilesSlavesTmp / etime(clock, clockStart1);
        timeLeft = (nrOfFiles - nrOfFilesReady) / filesPerSecond;

        waitbarMessage = sprintf('%.1f%% done by master\n%.1f%% done by slave(s)\n%.1f%% done overall\nestimated time left: %s', ...
          100 * nrOfFilesMaster / nrOfFiles, 100 * nrOfFilesSlaves / nrOfFiles, ...
          100 * nrOfFilesReady  / nrOfFiles, formattime(round(timeLeft), 'short'));
      else
        waitbarMessage = '';
      end
    end

  case 'init3'
    % called after user cancellation

    % change waitbar message
    waitbarMessage = sprintf('Removing parameter files.\n0.0%% done.\n\n');
    fractionReady = 0;

    % remember time
    clockStart1 = clock;
    clockUpdate = clock;

  case 'update3'
    % update during deleting parameter files (if user cancelled)
    if updateNow
      minFileNr        = varargin{1};
      maxFileNr        = varargin{2};
      lastFileNrMaster = varargin{3};
      nrOfFiles = maxFileNr - minFileNr + 1;
      fractionReady = (lastFileNrMaster - minFileNr + 1) / nrOfFiles;
      timeLeft = etime(clock, clockStart1) * (1 - fractionReady) / fractionReady;
      waitbarMessage = sprintf('Removing parameter files.\n%.1f%% done.\nestimated time left: %s\n', ...
        100 * fractionReady, formattime(round(timeLeft), 'short'));
    end

  case 'delete'
    % delete waitbar
    if waitbarExisting
      delete(waitbarHandle);
    end
    initialized = 0;
    return
    
  otherwise
    error('Command "%s" unknown.', command);
end

if ~initialized && ~isempty(waitbarMessage) && (...
    (fractionReady  > 0.05 && etime(clock, clockInit0) >  5.0) || ...
    etime(clock, clockInit0) > 10.0 )
  
  % remove all waitbars generated before
  delete(findobj('Tag', tag));

  % generate new waitbar
  waitbarHandle = waitbar(fractionReady, waitbarMessage, 'Name', 'Multicore progress', 'Tag', tag, ...
    'CreateCancelBtn', {@cancelCallback, multicoreCancelHandle});
  set(waitbarHandle, 'HandleVisibility', 'on', 'CloseRequestFcn', 'closereq');
  initialized = 1;
  clockUpdate = clock;
end

if initialized && waitbarExisting && updateNow
  % update waitbar
  waitbar(fractionReady, waitbarHandle, waitbarMessage);
  clockUpdate = clock;
end

end % function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cancelCallback(hObject, eventdata, multicoreCancelHandle) %#ok
%CANCELCALLBACK  Cancel multicore computation on user request.
%   This callback function is used to avoid having to use "hObject" and
%   "eventdata" in function multicoreCancel above.

% remove cancel button
delete(hObject);

% call cancel function
multicoreCancelHandle();

end % function

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
  fprintf('\nExamples for strings returned by function %s.m:\n', mfilename);
  time = [0 1e-4 0.1 1 1.1 2 60 61 62 120 121 122 3600 3660 3720 7200 7260 7320 ...
    3600*24 3600*25 3600*26 3600*48 3600*49 3600*50];
  for k=1:length(time)
    fprintf('time = %6g, timeString = ''%s''\n', time(k), formattime(time(k)));
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

end % function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fHandles = getFunctionHandles(functionHandleCell, index)
  
  if isa(functionHandleCell, 'function_handle')
    % return function handle as it is
    fHandles = functionHandleCell;
  elseif iscell(functionHandleCell) 
    if all(size(functionHandleCell) == [1 1])
      % return function handle
      fHandles = functionHandleCell{1};
    else
      if length(index) == 1
        % return function handle
        fHandles = functionHandleCell{index};
      else
        % return function handle cell
        fHandles = functionHandleCell(index);
      end
    end
  else
    error('Input type unknown.');
  end

end % function

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

end % function
