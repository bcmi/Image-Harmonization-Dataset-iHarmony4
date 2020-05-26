function [scores] = CaffeVGGBatch(ims, use_gpu, gpu_id, net_model, net_weights)
nImgs =numel(ims);

scores = cell(nImgs, 1);
CaffeReset();
net = CaffeInit(use_gpu, gpu_id, net_model, net_weights);
for n = 1 : nImgs
%     fprintf('process image (%s)\n', ims{n});
    s= CaffeVGG(ims{n}, net,true);

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

CaffeReset();

end
