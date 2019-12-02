function [] = ColorAdjustmentBatch(srcList, tgtList, maskList, rstList, opts, net)
ext = opts.EXT; 
nImgs = numel(srcList);
sz = [256,256];

for n= 1: nImgs
    fprintf('recolor (%s)\n', srcList{n});
    resultpath = [rstList{n} ext '.png'];
    matpath = [rstList{n} ext '.mat'];
    pastepath = [rstList{n} '_cut_and_paste.png'];
    src = imresize(imread(srcList{n}), sz);
    tgt = imresize(imread(tgtList{n}), sz);
    mask = imresize(imread(maskList{n}),sz);
    mask = MakeIm3(mask);
    result = OptimizeColorAdjustment(src, tgt, mask, opts, net);
    if ~isempty(result)
        imwrite(result.final_result, resultpath); 
        imwrite(result.cut_and_paste, pastepath); 
        save(matpath, 'result');
    end
end
end
