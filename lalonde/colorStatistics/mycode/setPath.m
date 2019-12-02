%% Path setup for the color statistics project

clear global;
global logFileRoot;

% host-dependent paths
[a, host] = system('hostname');

logFileRoot = getPathName('logs');
path3rdParty = getPathName('code', '3rd_party');
pathMyCode = getPathName('code', 'mycode');
pathUtils = getPathName('codeUtils');
pathUtilsPrivate = getPathName('codeUtilsPrivate');

%% Turn off some annoying warnings
warning off Images:initSize:adjustingMag;

% Restore to initial state
restoredefaultpath;

%% Setup project paths
addpath(genpath(pathMyCode));
addpath(genpath(pathUtils));
addpath(genpath(path3rdParty));
addpath(genpath(fullfile(pathUtilsPrivate, '3rd_party', 'vlfeat-0.9.14')));
vl_setup;
