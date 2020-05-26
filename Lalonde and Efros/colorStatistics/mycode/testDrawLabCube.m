% Test function to draw the L*a*b* cube (a slice along the L axis)

addpath ../../3rd_party/color;

L = 100;

[a, b] = meshgrid(-100:100, -100:100);

labImg = [reshape(repmat(L, size(a)), numel(a), 1), reshape(a, numel(a), 1), reshape(b, numel(b), 1)];

nbBins = 16;
nbDivsAB = (200 / nbBins);
nbDivsL = (100 / nbBins);

labImg = reshape(labImg, length(a), length(a), 3);
labImg(:,:,2:3) = fix(labImg(:,:,2:3) ./ nbDivsAB - sign(labImg(:,:,2:3)).*0.5) .* nbDivsAB;
labImg(:,:,1) = fix(labImg(:,:,1) ./ nbDivsL - sign(labImg(:,:,1)).*0.5) .* nbDivsL;

% convert to rgb
rgbImg = lab2rgb(reshape(labImg, numel(a), 3));
rgbImg = reshape(rgbImg, length(a), length(a), 3) .*255;

imshow(uint8(rgbImg));