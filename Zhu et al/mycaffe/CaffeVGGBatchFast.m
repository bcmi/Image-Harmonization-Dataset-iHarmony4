function [scores] = CaffeVGGBatchFast(ims, net, isCrop) %use_gpu, gpu_id, net_model, net_weights)
nImgs =numel(ims);
% nImgs =10; % for test
% scores = zeros(2, nImgs);
scores = cell(nImgs, 1);
% net = CaffeInit(use_gpu, gpu_id, net_model, net_weights);
for n = 1 : nImgs
    %     fprintf('%s\n', ims{n});
    s= CaffeVGG(ims{n}, net, isCrop);
    %     score = max(s,[], 2);
    % %     score(1) = min(s(1, :));
    % %     score(2) = max(s(2,:));
    if ndims(s) == 2
        scores{n} = mean(s, 2);
    end
    if ndims(s) == 4
        tmp = mean(s, 4);
        scores{n}=tmp(:);
    end
    if mod(n, 100) == 0
        fprintf('vgg batch (%d/%d) progress %3.3f%%\n', n, nImgs, n/nImgs*100);
    end
end
% CaffeReset();

end
