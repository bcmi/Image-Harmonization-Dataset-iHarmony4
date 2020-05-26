function [results] = PredictPLACELabel(ims, imgList)
load('../CNN/PLACE_labels.mat');
verbose = 1; 
model = '../CNN/places205CNN_iter_300000.caffemodel';
prototxt = '../CNN/places205CNN_deploy.prototxt';%deploy [hack]
usegpu = 1;
topK = 5; 
[score, sz] = PlaceCaffeBatch(ims, usegpu, prototxt, model);
nImgs = numel(ims);
results = cell(nImgs, 1);
for n = 1 : nImgs
    pred = score(:,n);
    result.pred =  pred;
    result.labels = label_list;
    [s, ids] = sort(pred, 'descend');
    result.top_pred = s(1:topK);
    result.top_labels = label_list(ids(1:topK));
    pred =  pred+eps; 
    pred = pred ./ sum(pred);
    result.scene_entropy = sum(-pred.*log2(pred));
    results{n} = result; 
    if verbose == 1
        fprintf('%s\n', imgList{n});
        for k = 1 : topK
            fprintf('(%s=%3.3f) ', result.top_labels{k}, result.top_pred(k));
        end
        fprintf('\nentropy = %3.3f\n', result.scene_entropy); 
    end
end
end

