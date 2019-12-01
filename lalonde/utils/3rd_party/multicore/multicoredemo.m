function multicoredemo(multicoreDir)
%MULTICOREDEMO  Introduction to parallel processing on multiple cores.
%   MULTICOREDEMO is a heavily comment demo function. It runs function
%   TESTFUN with different parameters using function STARTMULTICOREMASTER.
%   Open one or more other Matlab sessions on a multi-core machine and
%   start function STARTMULTICORESLAVE to see the effect of the
%   parallelization. Function STARTMULTICOREMASTER will be called several
%   times, after each run the elapsed time is displayed.
%
%   Please feel free to edit this function to get into working with the
%   multicore package. For a quick start, you can use the default settings
%   in this function. To optimize performance in your specific application,
%   have a look at the paramters nrOfEvalsAtOnce and maxEvalTimeSingle
%   explained below.  
%
%   MULTICOREDEMO(DIRNAME) uses directory DIRNAME for temporary files. Use
%   this notation to test the parallelization of different machines that
%   have access to a common directory.
%
%   <a href="multicore.html">multicore.html</a>  <a href="http://www.mathworks.com/matlabcentral/fileexchange/13775">File Exchange</a>  <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=GPUZTN4K63NRY">Donate via PayPal</a>
%
%   Markus Buehren
%   Last modified 04.07.2011
%
%   See also STARTMULTICOREMASTER, STARTMULTICORESLAVE, TESTFUN.

% If debug mode is activated, more info will be displayed.
debugMode = 0;

% Check if directory is given, otherwise use standard directory
if exist('multicoreDir', 'var')
  settings.multicoreDir = multicoreDir;
else
  settings.multicoreDir = '';
end

% The function TESTFUN used in the following is called with two parameters,
% fEvalTimeSingle and k. It will do some stupid stuff until fEvalTimeSingle
% seconds have passed and return the number k.

% Set the time in seconds that each call of function TESTFUN shall take:
fEvalTimeSingle = 0.5; % default: 0.5

% Now set the time in seconds all function evaluations shall take together.
% Use an integer multiple of fEvalTimeSingle above. 
fEvalTimeAll = 20; % default: 20

% The number of parameter sets to be given to STARTMULTICOREMASTER is
% computed from the settings above:
nrOfEvals = ceil(fEvalTimeAll / fEvalTimeSingle); % do not change!

% Here you can tell MULTICORE to do nrOfEvalsAtOnce function evaluations
% after each other in each process before saving/loading results. Using a
% number larger than one for nrOfEvalsAtOnce reduces the overhead for
% inter-process communication. For example, if you have 1000 functions
% evaluations to do where each function evaluation takes around 0.1
% seconds, you could set nrOfEvalsAtOnce to 50. This way, file accesses for
% inter-process communications only need to be done every 5 seconds or so
% instead of 10 times per second. Please feel free to play around with this
% parameter! As a RULE OF THUMB, a single "job", i.e. nrOfEvalsAtOnce
% function evaluations, shall never take less than 2 seconds in order to
% keep the inter-communication overhead low.
settings.nrOfEvalsAtOnce = 4; % default: 4

% The master will wait for slave processes to finish already started jobs.
% However, if a single function execution takes longer than
% maxEvalTimeSingle (or if nrOfEvalsAtOnce function executions take longer
% than nrOfEvalsAtOnce * maxEvalTimeSingle), the master will suppose that
% the slave was killed and do the job himself. The timeout threshold
% maxEvalTimeSingle should be greater than the mean function execution time
% on the slowest slave machine. Good INITIAL VALUES are 1.1, 1.5 or 2.0
% times the expected maximum execution time.  
settings.maxEvalTimeSingle = min(fEvalTimeSingle * 2, 0.5);

% Select the multicore working mode. If masterIsWorker is set to TRUE, the
% master will fully work on the given tasks, leading to MAXIMUM
% PERFORMANCE. If masterIsWorker is set to FALSE, the master will only act
% as a coordinator and not evaluate the objective function itself - except
% in case a timeout is detected. This mode is useful if you want to run the
% master process in the background on your own computer and let other
% machines do the work. In both cases, the complete work will be finished
% unless the master itself is killed. If the master only acts as
% coordinator and all slaves are killed, the master will do all the work.
% Much time will be lost as the master always waits for the slaves to
% complete a job before starting to work on it himself.
settings.masterIsWorker = true; % default: true

% If you set settings.useWaitbar to true, a waitbar will be displayed to
% inform about the current progress.
settings.useWaitbar = true;

% Set handle to postprocessing function
% settings.postProcessHandle   = @postprocessdemo
% settings.postProcessUserData = datestr(now);

% Function STARTMULTICOREMASTER will be run nrOfRuns times. To observe the
% advantage of parallel processing, let the function run some times without
% any slave processes running, then start your slaves.
nrOfRuns = 5;

% After running STARTMULTICOREMASTER several times, it will be started once
% with a different temporary directory unknown to the slaves. This means
% that STARTMULTICOREMASTER will work down all the jobs without any slave
% support. Set runWithoutSlaves to zero if you don't need this.
runWithoutSlaves = 1;

% For a performance comparison with the parallel computing toolbox of 
% Matlab, the test function is called within a parfor-loop if the parallel
% computing toolbox is installed. 
% Note: The parfor loop will show a better performance, but remember that
% you need to buy a license!
runWithParfor = 1;

% Finally, function TESTFUN is called directly with the given parameters to
% see the raw execution time without any multicore advantage but also
% without any overhead. Compare the elapsed time of the direct calls with
% those before.
runDirectly = 1;

% Build cell array containing all nrOfEvals parameter sets. TESTFUN will be
% called with the parameters fEvalTimeSingle and k.
parameterCell = cell(1, nrOfEvals);
for k = 1:nrOfEvals
  parameterCell{1,k} = {fEvalTimeSingle, k};
end

if debugMode
  disp('********** Parameters set in multicoredemo.m:');
  disp(sprintf('masterIsWorker    = %d',   settings.masterIsWorker));
  disp(sprintf('fEvalTimeSingle   = %.2f', fEvalTimeSingle));
  disp(sprintf('nrOfEvalsAtOnce   = %d',   settings.nrOfEvalsAtOnce));
  disp(sprintf('nrOfEvals         = %d',   nrOfEvals));
  disp(sprintf('maxEvalTimeSingle = %.2f', settings.maxEvalTimeSingle));
end

% Let the show begin!
messages = {};
for n = 1:nrOfRuns
  
  % Call function STARTMULTICOREMASTER.
  t0 = mbtime;
  resultCell = startmulticoremaster(@testfun, parameterCell, settings);
  messages{end+1} = sprintf('Elapsed time running STARTMULTICOREMASTER: %.2f seconds.', mbtime - t0); %#ok
  disp(messages{end});
  
  % Check if returned result is correct.
  if isempty(resultCell)
    disp('It seems that function STARTMULTICOREMASTER was cancelled by the user.');
  else
    for k = 1:nrOfEvals
      if resultCell{1,k} ~= k
        disp('Wrong result returned by STARTMULTICOREMASTER!!!');
        break
      end
    end
  end
  if debugMode && (n < nrOfRuns || runWithoutSlaves || runDirectly)
    disp(sprintf('\n\n\n\n'));
  end
end

% Now run STARTMULTICOREMASTER with a different temporary directory unknown
% to the slaves. This means that STARTMULTICOREMASTER will work down all
% the jobs without any slave support.
if runWithoutSlaves
  if debugMode
    disp('Now running without any slave support.');
  end

  % The following directory is unknown to the slave processes, thus the
  % master will do the whole work alone
  multicoreDir2 = fullfile(tempdir2, 'multicorefiles_temp');
  settingsTemp = settings;
  settingsTemp.multicoreDir = multicoreDir2;
  if ~exist(multicoreDir2, 'dir')
    mkdir(multicoreDir2);
  end
  
  % Call function STARTMULTICOREMASTER.
  t0 = mbtime;
  resultCell = startmulticoremaster(@testfun, parameterCell, settingsTemp);
  messages{end+1} = sprintf('Elapsed time without slave support:        %.2f seconds.', mbtime - t0);
  disp(messages{end});

  if debugMode && runDirectly
    disp(sprintf('\n\n\n\n'));
  end
end

if runWithParfor && exist('matlabpool', 'file')
  if debugMode
    disp('Now running TESTFUN in parfor-loop.');
  end
  
  if matlabpool('size') == 0
    disp('Now opening Matlab pool with default configuration.');
    matlabpool('open');
  end
  
  % Run function TESTFUN nrOfEvals times in a parfor-loop.
  t0 = mbtime;
  resultCell2 = cell(size(parameterCell));
  parfor k = 1:nrOfEvals
    resultCell2{k} = testfun(parameterCell{k}{:});
  end
  messages{end+1} = sprintf('Elapsed time running TESTFUN in parfor-loop: %.2f seconds.', mbtime - t0);
  disp(messages{end});

  % Compare the results of STARTMULTICOREMASTER and direct function calls.
  if ~isequal(resultCell, resultCell2)
    disp('Warning: Call to STARTMULTICOREMASTER and running TESTFUN in parfor-loop returned different results!');
    if debugMode
      resultCell, resultCell2 %#ok
    end
  end  
end

  
% After running STARTMULTICOREMASTER several times, function TESTFUN is
% called directly with the given parameters to see the raw execution time
% without any multicore advantage but also without any overhead. 
if runDirectly
  if debugMode
    disp('Now running TESTFUN directly.');
  end
  
  % Run function TESTFUN nrOfEvals times in a loop.
  t0 = mbtime;
  resultCell2 = cell(size(parameterCell));
  for k = 1:nrOfEvals
    resultCell2{k} = testfun(parameterCell{k}{:});
  end
  messages{end+1} = sprintf('Elapsed time running TESTFUN directly:     %.2f seconds.', mbtime - t0);
  disp(messages{end});

  % Compare the results of STARTMULTICOREMASTER and direct function calls.
  if ~isequal(resultCell, resultCell2)
    disp('Warning: Call to STARTMULTICOREMASTER and directly running TESTFUN returned different results!');
    if debugMode
      resultCell, resultCell2 %#ok
    end
  end
end

if debugMode
  disp(sprintf('\n\n\n\n'));
  disp('Final result:');
  for k=1:length(messages)
    disp(messages{k});
  end
end

