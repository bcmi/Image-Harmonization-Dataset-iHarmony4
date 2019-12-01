%% Path setup for the geometric context code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize the random number generator (initialized to the same value each time!)
rand('state', sum(100*clock));

path3rdParty = '/nfs/hn01/jlalonde/code/matlab/trunk/3rd_party';
pathMyCode = '/nfs/hn01/jlalonde/code/matlab/trunk/mycode/';

if isdeployed
    return;
end

%% Setup mycode paths
addpath(fullfile(pathMyCode, 'database'));
addpath(fullfile(pathMyCode, 'xml'));
addpath(fullfile(pathMyCode, 'histogram'));


%% Setup 3rd party paths
% Arguments parsing
addpath(fullfile(path3rdParty, 'parseArgs'));
% Useful stuff
addpath(fullfile(path3rdParty, 'util'));
% Color 
addpath(fullfile(path3rdParty, 'color'));
% Labelme
addpath(fullfile(path3rdParty, 'LabelMeToolbox'));

%% Setup geometric context paths
appPath = fullfile(path3rdParty, 'geometricContext');
addpath(appPath);
addpath(fullfile(appPath, 'boosting'));
addpath(fullfile(appPath, 'crf'));
addpath(fullfile(appPath, 'geom'));
addpath(fullfile(appPath, 'ijcv06'));
addpath(fullfile(appPath, 'mcmc'));
addpath(fullfile(appPath, 'textons'));
addpath(fullfile(appPath, 'tools', 'drawing'));
addpath(fullfile(appPath, 'tools', 'misc')); 
addpath(fullfile(appPath, 'tools', 'weightedstats'));
