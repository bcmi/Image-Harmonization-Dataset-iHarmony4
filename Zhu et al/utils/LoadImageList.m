%LOADIMAGELIST: list all the image files in the given directory.
% Support image format: png, jpg, jpeg, bmp
% Author: Jun-Yan Zhu (junyanz@eecs.berkeley.edu)
% Input:
%     imgDir (string): the directory that stores the images.
% Output:
%     imgList (a cell array of strings): each cell stores the name of a
%     image. The strings are sorted by alphabetical order.
function [imgList] = LoadImageList(imgDir, keyword)
if ispc
    formats = {'png', 'jpg', 'jpeg', 'bmp'};
else
    formats = {'png', 'jpg', 'jpeg', 'bmp', 'PNG', 'JPG', 'JPEG', 'BMP'};
end
nFormats = numel(formats);
imgLists = cell(nFormats, 1);
for n = 1 : numel(formats)
    imgLists{n} = dir(fullfile(imgDir, ['*.' formats{n}]));
end

imgList = cat(1, imgLists{:});
[~, idx] = sort({imgList.name});
imgList = {imgList(idx).name};
if nargin == 2 && ~isempty(keyword)
    ids = CellStrFind(imgList, keyword);
    imgList = imgList(ids);
end
end
