function launchMulticoreSlaves(hosts, nbProcesses, gitRepos, varargin)
% Launches a bunch of multicore slaves for parallel processing
% 
%   launchMulticoreSlaves(hosts, nbProcesses, gitRepos, ...)
%
%
% 
% See also:
%   startmulticoreslave
%   killMulticoreSlaves
% 
% ----------
% Jean-Francois Lalonde

% whether to display errors or warnings
errFun = @error; 

% name to use for screen session
screenName = 'matlabSlaves';

% over-ride defaults
sleepTime = []; 

% matlab full path
matlabCmd = '/Applications/MATLAB_R2014b.app/bin/matlab -nodesktop -nosplash 2> /dev/null';

parseVarargin(varargin{:});

assert(length(hosts) == length(nbProcesses), ...
    'Must have as many hosts as nbProcesses');

% if there's at least one host that's not localhost
if any(~strcmp(hosts, 'localhost'))
    curPath = pwd;
    
    % Make sure that all the source repos are committed and up-to-date.
    srcBranch = cell(1, length(gitRepos));
    
    for i_repo = 1:length(gitRepos)
        % go to the repo directory (the main one).
        cd(getPathName(gitRepos{i_repo}));
        srcBranch{i_repo} = checkRepo(gitRepos{i_repo}, 'Source');
    end

    % Make sure the remotes are up-to-date as well.
    for i_repo = 1:length(gitRepos)
        remotePath = getPathName(false, gitRepos{i_repo});
        if ~exist(remotePath, 'dir')
            error('multicore:noremote', ...
                ['Remote directory (%s) doesn''t exist. ', ...
                'Prehaps it''s not mounted?'], remotePath);
        end
        cd(remotePath);
        checkRepo(gitRepos{i_repo}, 'Network', srcBranch{i_repo});
    end
    
    % we're done checking all source and remote repos
    cd(curPath);
    
    % we'll use a network path for the slaves
    if isempty(sleepTime)
        sleepTime = 10; % alien07 doesn't seem to like it when we launch them too quickly
    end
    slavePath = getPathName(false, 'slaves');
else
    if isempty(sleepTime)
        sleepTime = 10;
    end
    slavePath = getPathName('slaves');
end

% Look at our slave path. Warn if it's non-empty.
% This is not a huge deal since next time we launch a multi-core process
% with startmulticoremaster it will remove the old files. But still, could
% be problematic.
f = getfilenames(slavePath);
if ~isempty(f)
    warning('multicore:nonempty', ['Slave directory non-empty! '...
        'Slaves will start processing immediately.']);
end

% Ok, all the code's in sync. 
% Now, launch the matlab processes, embedded in screen sessions.
for i_host = 1:length(hosts)
    if ~strcmp(hosts{i_host}, 'localhost')
        codePath = getPathName(false, 'code', 'mycode');
    else
        codePath = getPathName('code', 'mycode');
    end
    
    % check if it's already running
    checkCmd = 'screen -list | grep matlabSlaves | wc -l';
    if ~strcmp(hosts{i_host}, 'localhost')
        % ssh to the host first.
        checkCmd = sprintf('ssh %s "%s"', hosts{i_host}, checkCmd);
    end

    [~,c] = system(checkCmd);
    c = textscan(c, '%d');
    if c{1}==1
        errFun('multicore:already', ...
            ['Screen session already running on %s. \n', ...
            'Do screen -rd %s to re-attach to it'], ...
            hosts{i_host}, screenName);
    end
    
    % create the (detached) screen session
    cmd = sprintf('screen -Sdm %s; ', screenName);
    
    % then, create new screens in which matlab will be run N times
    baseCmd = sprintf('screen -S %s -X screen -fn -t matlab', ...
        screenName);
    for i_proc = 1:nbProcesses{i_host}
        curCmd = sprintf(['%s %d %s -r "cd %s; setPath; ', ...
            'startmulticoreslave(''%s'', struct(''debugMode'', 1));"; '], ...
            baseCmd, i_proc-1, matlabCmd, ...
            codePath, slavePath);
        % give it more time if it's on the network (?)
        cmd = cat(2, cmd, curCmd, sprintf('sleep %d; ', sleepTime));
    end

    if ~strcmp(hosts{i_host}, 'localhost')
        % ssh to the host first.
        cmd = strrep(cmd, '"', '\"');
        cmd = sprintf('ssh %s "%s"', hosts{i_host}, cmd);
    end
    
    % launch everything at once
    r = system(cmd);
    assert(r==0, 'There was a problem executing the command');
    
    fprintf('Launched %d slaves on %s\n', i_proc, hosts{i_host});
end

    function branchName = checkRepo(repoName, repoType, branchName)
        switch lower(repoType)
            case 'source'
                % check branch
                branchName = getBranchName();
                
            case 'network'
                % fetch from origin
                system('git fetch origin');
                
                % check that we're on the same branch as the source
                [curBranchName, upToDate] = getBranchName();
                if ~isequal(branchName, curBranchName)
                    cd(curPath);
                    errFun('multicore:branch', ...
                        ['%s repo ''%s'' is on the branch %s, while origin is '...
                        'on the branch %s! \n '...
                        'Do: git branch %s'], repoType, repoName, ...
                        curBranchName, branchName, branchName);
                end
                
                if upToDate ~= 0
                    cd(curPath);
                    errFun('multicore:up2date', ...
                        ['%s repo ''%s'' is not up to date wrt origin', ...
                        ' (behind %d)!\n' ...
                        'Do: git merge origin %s'], ...
                        repoType, repoName, upToDate, branchName);
                end
                    
                
            otherwise
                cd(curPath);
                error('Unsupported repo type. Must be either ''source'' or ''network''');
        end
        
        % check status
        [~,gitOutput] = system('git status --porcelain');
        
        if ~isempty(gitOutput)
            cd(curPath);
            errFun('multicore:repo', ...
                '%s repo ''%s'' has local modifications!', repoType, repoName);
        else
            fprintf('%s repo %s is on branch %s and up-to-date!\n', ...
                repoType, repoName, branchName);
        end
    end

    function [branchName, upToDate] = getBranchName()
        % Retrieves the branch name and whether the branch is up to date.
        %
        %
        
        [~,gitOutput] = system('git status -sb');
        % get the first line
        gitOutput = textscan(gitOutput, '%s\n', 1, 'delimiter', '\n');
        [~,s] = strtok(gitOutput{1}{1});
        % ignore the white space, get the branchname
        branchName = strtok(strtok(s), '...');
        
        % while we're at it, also compute if we're ahead/behind the remote
        if nargout > 1
            [~,s2] = strtok(s, '[');
            if isempty(s2)
                upToDate = 0;
            else
                a = textscan(s2, '[%s %d]', 1);
                if ~isempty(a) && ~isempty(a{2})
                    upToDate = a{2};
                else
                    upToDate = 0;
                end
            end
        end
    end
end

