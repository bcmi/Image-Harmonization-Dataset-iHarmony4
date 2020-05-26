function [] = ColorAdjustmentBatch_my(srcList, tgtList, maskList, rstList, opts, net,nImgs)
% ext = opts.EXT; 
sz = [256,256];

for n= 1: nImgs
    fprintf('recolor (%s)\n', srcList{n});
    resultpath = rstList{n};
    src=imread(srcList{n});
    h=size(src,1);
    w=size(src,2);
    ori_size=[h,w];
    src = imresize(src, sz);
    tgt = imread(tgtList{n});
    tgt = imresize(tgt, sz);
    mask = imread(maskList{n});
    mask = imresize(mask, sz);
    mask=mask(:,:,1);
    mask = mask/255;
    mask = MakeIm3(mask);
    src=src*mask;
    disp(src);
    result = OptimizeColorAdjustment(src, tgt, mask, opts, net);
    if ~isempty(result)
        imwrite(imresize(result.final_result,ori_size), resultpath); 
    end
end
end
