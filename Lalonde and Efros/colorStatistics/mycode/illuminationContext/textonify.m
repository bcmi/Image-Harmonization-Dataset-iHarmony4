function textonMap = textonify(img, filterBank, clusterCenters)
% Computes textons in an image given a filter bank and cluster centers
% 
%   textonMap = textonify(img, filterBank, clusterCenters)
% 
% ----------
% Jean-Francois Lalonde

% convert to grayscale
imgGray = rgb2gray(img);

% filter it
fprintf('Filtering image...'); tic;
filteredImg = fbRun(filterBank, imgGray);

% stack it into a nbPixel * nbDims vector
filteredImg = cellfun(@(x) reshape(x, [size(x,1)*size(x,2) 1]), filteredImg, 'UniformOutput', 0);
filteredImg = reshape(filteredImg, [1, size(filteredImg,1)*size(filteredImg,2)]);
filteredImg = [filteredImg{:}];

fprintf('Computing textons...');
ind = BruteSearchMex(clusterCenters, filteredImg');

[h,w,c] = size(img);
textonMap = reshape(ind, [h w]);
fprintf('done in %fs\n', toc);

