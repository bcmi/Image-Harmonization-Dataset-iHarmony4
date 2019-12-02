function recoloredImg = recolorImage(srcImg, objMask, tgtImg, bgMask, varargin)
% Recolors the object in an image with the ICCV'07 algorithm.
% 
%   img = recolorImage(srcImg, objMask, tgtImg, bgMask, <'Param1', 'Value1'>, ...)
% 
% Set tgtImg=[] if the object should be recolored according to the
% background in the same image.
%
%  

% parse inputs
% read arguments
defaultArgs = struct('UseLAB', 1, 'Display', 0, 'Sigma', 5);
args = parseargs(defaultArgs, varargin{:});

assert(islogical(objMask), 'Object mask must be logical');

srcImg = im2double(srcImg);
if isempty(tgtImg)
    tgtImg = srcImg;
    bgMask = ~objMask;
end

if args.UseLAB
    srcImg = rgb2lab(srcImg);
    tgtImg = rgb2lab(tgtImg);
end

% Parameters
nbClusters = 50;

% imgVector = reshape(img, [w*h c]);
srcImgVector = reshape(srcImg, [size(srcImg,1)*size(srcImg,2) size(srcImg,3)]);
tgtImgVector = reshape(tgtImg, [size(tgtImg,1)*size(tgtImg,2) size(tgtImg,3)]);

% Retrieve the background and object pixels
bgPixels = double(tgtImgVector(bgMask(:), :));
objPixels = double(srcImgVector(objMask(:), :));

%% Compute signatures
fprintf('Computing signatures...\n');
[centersObj, weightsObj, indsObj] = signaturesKmeans(objPixels, nbClusters);
[centersBg, weightsBg] = signaturesKmeans(bgPixels, nbClusters);

%% Compute the EMD between signatures
fprintf('Computing EMD...\n');
distMat = pdist2(centersObj, centersBg);
[distEMD, flowEMD] = emd_mex(weightsObj', weightsBg', distMat);

if args.Display
    emdFig = figure(4); hold on;
    plotEMD(emdFig, centersObj, centersBg, flowEMD);
    
    if args.UseLAB
        colorspace = 'lab';
    else
        colorspace = 'rgb';
    end
        
    plotSignatures(emdFig, centersObj, weightsObj, colorspace);
    plotSignatures(emdFig, centersBg, weightsBg, colorspace);
    
    title(sprintf('K-means clustering with k=%d on image colors, EMD=%f', nbClusters, distEMD));
    
    if args.UseLAB
        xlabel('L'), ylabel('A'), zlabel('B');
    else
        xlabel('R'), ylabel('G'), zlabel('B');        
    end
end


%% Recolor
fprintf('Recoloring...\n');
sigma = args.Sigma;
[imgTgtNN, recoloredImg] = recolorImageFromEMD(centersBg, centersObj, srcImg, ...
    indsObj, find(objMask(:)), flowEMD, sigma);

if args.UseLAB
    recoloredImg = lab2rgb(recoloredImg);
end

if args.Display
    figure(7), subplot(1,2,1), imshow(lab2rgb(srcImg)), title('Original image'), ...
        subplot(1,2,2), imshow(recoloredImg), title(sprintf('Weighted nn cluster center, \\sigma=%d', sigma));
end
