function [modelFile] = LoadLatestModel(modelFold)
modelList = dir(fullfile(modelFold, 'model_iter_*.caffemodel'));
nModels = numel(modelList);
if nModels == 0
    modelFile = [];
else
    iters = zeros(nModels, 1);
    for k = 1 : nModels
        modelname = modelList(k).name;
        iters(k) = sscanf(modelname, 'model_iter_%d.caffemodel');
    end
    max_iter = max(iters);
    modelFile = fullfile(modelFold, sprintf('model_iter_%d.caffemodel', max_iter));
    fprintf('use model %s)\n', modelFile);
end
end