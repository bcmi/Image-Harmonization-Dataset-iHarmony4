function testPreloadData 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

inputDir = '/nfs/hn01/jlalonde/results/colorStatistics/trainingData/colorStatistics/lab/1stOrder/';

% Read all .mat files
files = dir(fullfile(inputDir, '*.mat'));

% Load all .mat files
for i=1:length(files)
    load(fullfile(inputDir, files(i).name));
    trainingData.data(i).hist = hist1stOrder;
    trainingData.data(i).name = files(i).name;
end
% delete whatever was there before
delete(fullfile(inputDir, 'all.mat'));
save(fullfile(inputDir, 'all.mat'), 'trainingData');

% 
% % Split the 2nd order in half (cuz it's too big otherwise)
% % inputDir = '/nfs/hn01/jlalonde/results/colorStatistics/trainingData/colorStatistics/rgb/2ndOrder/';
% inputDir = '/usr2/home/jlalonde/colorStatistics/trainingData/colorStatistics/rgb/2ndOrder/';
% 
% % Read all .mat files
% files = dir(fullfile(inputDir, '*.mat'));
% 
% % Load first half .mat files
% nbDivs = 4;
% nbExamples = floor(length(files)/nbDivs);
% for j=1:nbDivs
%     fprintf('Saving %d/%d of the data\n', j, nbDivs);
%     tic
%     for i=1:nbExamples
%         load(fullfile(inputDir, files(i + (j-1)*nbExamples).name));
%         trainingData{i} = hist2ndOrder;
%     end
%     toc;
%     save(fullfile(inputDir, sprintf('all%d.mat', j)), 'trainingData');
%     clear trainingData;
% end