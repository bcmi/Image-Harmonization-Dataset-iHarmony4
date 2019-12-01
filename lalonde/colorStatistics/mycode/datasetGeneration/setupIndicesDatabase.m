function setupIndicesDatabase

filteredDbFull = loadDatabaseFast('/nfs/hn01/jlalonde/results/colorStatistics/dataset/filteredDb/', '');

realInd = find(arrayfun(@(x) ~str2double(x.document.image.generated), filteredDbFull));

% randomly select real images
N = 1000;
randInd = randperm(length(realInd));
realDbInd = realInd(randInd(1:N));
restDbInd = realInd(randInd(N:end));

realDb = filteredDbFull(realDbInd);

save('/nfs/hn01/jlalonde/results/colorStatistics/databases/realDb.mat', 'realDb');

generatedInd = find(arrayfun(@(x) str2double(x.document.image.generated), filteredDbFull));
filteredDb = filteredDbFull(sort([generatedInd restDbInd]));

save('/nfs/hn01/jlalonde/results/colorStatistics/databases/filteredDb.mat', 'filteredDb');

