%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function convertWildDatabase
%   Converts the WILD database to my own xml format (for easy retrieval of ground truth, etc)  
% 
% Input parameters:
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function extractWildData
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup paths
addpath ../;
addpath ../../../3rd_party/wild;

outputBasePath = '/usr3/jlalonde/WILD/wildDb';

%% load the database
wildDb = loadDatabaseFast(outputBasePath, '*');

%% extract meaningful information
wildYear = arrayfun(@(x) str2double(x.document.date.year), wildDb);
wildMonth = arrayfun(@(x) lower(x.document.date.month), wildDb, 'UniformOutput', 0);
wildDay = arrayfun(@(x) str2double(x.document.date.day), wildDb);
wildHour = arrayfun(@(x) str2double(x.document.date.hour), wildDb);

wildVisibility = arrayfun(@(x) str2double(x.document.gt.visibility), wildDb);
wildSkyConditions = arrayfun(@(x) lower(x.document.gt.skyConditions), wildDb, 'UniformOutput', 0);
wildRelHumidity = arrayfun(@(x) str2double(x.document.gt.relHumidity), wildDb);
wildTemperature = arrayfun(@(x) str2double(x.document.gt.temperature), wildDb);
wildDewPoint = arrayfun(@(x) str2double(x.document.gt.dewPoint), wildDb);
wildWeather = arrayfun(@(x) lower(x.document.gt.weather), wildDb, 'UniformOutput', 0);

%% Save information
save(fullfile(outputBasePath, 'wildDb.mat'), 'wildDb', 'wildYear', 'wildMonth', 'wildDay', 'wildHour', ...
    'wildVisibility', 'wildSkyConditions', 'wildRelHumidity', 'wildTemperature', 'wildDewPoint', 'wildWeather');

