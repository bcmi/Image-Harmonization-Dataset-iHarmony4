%% Setup variables and paths
addpath ../../3rd_party/color;

nbBins = 16;

% quantize the image into bins
nbDivsAB = (200 / nbBins);
nbDivsL = (100 / nbBins);%nbBins);

%% Generate all the possible colors in one vector
rangeAB = unique(fix([-100:0.1:100] ./ nbDivsAB - sign([-100:0.1:100]).*0.5) .* nbDivsAB);
rangeL = unique(fix([0:0.1:100] ./ nbDivsL - sign([0:0.1:100]).*0.5) .* nbDivsL);
[a,b,c] = meshgrid(rangeAB, rangeAB, rangeL);
labRange = [c(:) b(:) a(:)];

%% Convert to RGB
rgbRange = uint8(lab2rgb(labRange)*255);

%% Keep only the unique values
[tmp,i,j] = unique(rgbRange, 'rows');
% the i's will be sorted according to the rows of rgbRange. 
% We don't want that
i = sort(i);
% rgbRange = rgbRange(i,:);

%% Find meaningful ordering -> by hue?
hsvRange = rgb2hsv(rgbRange);

% sort the hues
[huesSorted, ind] = sortrows(hsvRange(:,[1 3 2]));

% re-arrange
% rgbRange = rgbRange(ind, :);    

% plot useful stuff
% figure; hold on; title('Hue variation');
% plot(hsvRange(ind,1), 'LineWidth', 2);
% plot(hsvRange(ind,2), 'LineWidth', 2);
% plot(hsvRange(ind,3), 'LineWidth', 2);

%% Reshape into an image

rgbRange = permute(rgbRange, [3 1 2]);
rgbRange = repmat(rgbRange, 100, 1);

% display the result in an image (?)
% imshow(rgbRange(1, 1000:2000, :));
figure; imshow(rgbRange);
