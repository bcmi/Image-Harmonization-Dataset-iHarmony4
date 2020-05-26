function demo
sz = [256,256];
recolorSigma = 75;
imgPath = 'demoData/a0002_1_4.jpg';
name_parts = regexp(imgPath,'_','split');
objMaskPath = [name_parts{1,1},'_',name_parts{1,2},'.png'];
img = imread(imgPath);
objMask = imread(objMaskPath);
objMask = objMask(:,:,1);
objMask = objMask/255;
objMask = logical(objMask);
img = imresize(img, sz);
objMask = imresize(objMask, sz);
bgImg = []; bgMask = [];
imgRecolored = recolorImage(img, objMask, bgImg, bgMask, ...
    'UseLAB', 1, 'Display', 0, 'Sigma', recolorSigma);
% figure(1); clf;
% subplot 121; imshow(img); title('Original image');
% subplot 122; imshow(imgRecolored); title('Recolored image');
result_path = 'demoData/result.jpg';
imwrite(imgRecolored,result_path);



