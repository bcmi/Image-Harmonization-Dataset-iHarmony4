%% Test program to evaluate different quantization alternatives

addpath ../../3rd_party/color;

%
imgs{1} = '/usr1/projects/labelmeSubsampled/Images/nov6_static_outdoor/img_0470.jpg';
imgs{2} = '/usr1/projects/labelmeSubsampled/Images/nov6_static_outdoor/img_0480.jpg';
% imgs{3} = '/usr1/projects/labelmeSubsampled/Images/static_barcelona_street_city_outdoor_2005/img_0285.jpg';
% imgs{4} = '/usr1/projects/labelmeSubsampled/Images/static_barcelona_street_city_outdoor_2005/img_0320.jpg';

% try different possibilities for quantization
divsAB = [16 16 32 32];
divsL = [16 32 16 32];

mins = [0 -100 -100];
maxs = [100 100 100];


figure; 
for i=1:length(imgs)
    img = imread(imgs{i});
    imshow(img); drawnow;
    labImg = rgb2lab(img);
    
    nbPixels = size(img,1)*size(img,2);
    
    for j=1:length(divsAB)
        nbDivsAB = (200 / divsAB(j));
        nbDivsL = (100 / divsL(j));
        
        labImgQ = reshape(labImg, size(labImg,1)*size(labImg,2), size(labImg,3));
        labImgQ = floor((labImgQ - repmat(mins, nbPixels, 1)) ./ repmat([divsL(j) divsAB(j) divsAB(j)], nbPixels, 1));
        
        labImgQ = labImg;
        labImgQ(:,:,2:3) = fix(labImg(:,:,2:3) ./ nbDivsAB - sign(labImg(:,:,2:3)).*0.5) .* nbDivsAB;
        labImgQ(:,:,1) = fix(labImg(:,:,1) ./ nbDivsL - sign(labImg(:,:,1)).*0.5) .* nbDivsL;

        % test: convert back to rgb and show image
        rgbImg = lab2rgb(reshape(labImgQ, size(img,1)*size(img,2), 3));
        rgbImg = reshape(rgbImg, size(img,1), size(img,2), 3);
        imshow(rgbImg);
%         ssd = sum(sum(sqrt(sum((double(rgbImg.*255) - double(img)).^2, 3))));
%         title(sprintf('%dx%dx%d, requires %d MB', divsL(j), divsAB(j), divsAB(j), divsL(j)^2*divsAB(j)^4/1024^2));
        drawnow;
        fprintf('%dx%dx%d, requires %d MB\n', divsL(j), divsAB(j),divsAB(j), divsL(j)^2*divsAB(j)^4*8/1024^2);
%         imwrite(rgbImg, sprintf('img%d_%d_%d_%d.jpg', i, divsL(j), divsAB(j), divsAB(j)));
    end
%     imwrite(img, sprintf('img%d_orig.jpg', i));
end
