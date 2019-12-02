function killMulticoreSlaves(hosts, varargin)
% Kill the remote slaves
%
%   killMulticoreSlaves(hosts)
%
% See also:
%   launchMulticoreSlaves
%
% ----------
% Jean-Francois Lalonde

% This screen name must be the same as the one used in
% launchMulticoreSlaves
screenName = 'matlabSlaves';

parseVarargin(varargin{:});

% do this to get list of running slave matlab processes on a host
for i_host = 1:length(hosts)
    % first, retrieve the list of running matlab processes
    cmdList = 'ps au | grep MATLAB | grep no | awk ''{ print $2 }''';
    if ~strcmp(hosts{i_host}, 'localhost')
        % we'll need to ssh beforehand
        cmdList = sprintf('ssh %s %s', hosts{i_host}, cmdList);
    end
    [~,c] = system(cmdList);
    
    % kill the screen session
    cmd = sprintf('screen -S %s -X quit; sleep 1; ', screenName);
    
    if isempty(c)
        fprintf('No running processes on host %s\n', hosts{i_host});
    else
        % kill all the matlab processes
        pids = textscan(c, '%d');
        pids = pids{1};
        
        for i_pid = 1:length(pids)
            cmd = cat(2, cmd, sprintf('kill -9 %d; sleep 1; ', pids(i_pid)));
        end
        
        fprintf('Killing %d processes on %s\n', floor(length(pids)/2), ...
            hosts{i_host});
    end
    
    if ~strcmp(hosts{i_host}, 'localhost')
        % we'll need to ssh beforehand
        cmd = sprintf('ssh %s "%s"', hosts{i_host}, cmd);
    end
    system(cmd);
    
end