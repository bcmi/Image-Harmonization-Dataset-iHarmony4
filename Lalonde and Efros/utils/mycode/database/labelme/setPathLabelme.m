%% Path setup for labelme processing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isdeployed
    return;
end

%% Initialize the random number generator (initialized to the same value each time!)
rand('state', sum(100*clock));

path3rdParty = '/nfs/hn01/jlalonde/code/matlab/trunk/3rd_party';
pathMyCode   = '/nfs/hn01/jlalonde/code/matlab/trunk/mycode';

%% Setup mycode paths
addpath(fullfile(pathMyCode, 'database'));
addpath(fullfile(pathMyCode, 'database', 'labelme'));
addpath(fullfile(pathMyCode, 'xml', 'load_xml'));

%% Setup 3rd party paths
% Arguments parsing
addpath(fullfile(path3rdParty, 'parseArgs'));
% Useful stuff
addpath(fullfile(path3rdParty, 'util'));
% Labelme
addpath(fullfile(path3rdParty, 'LabelMeToolbox'));