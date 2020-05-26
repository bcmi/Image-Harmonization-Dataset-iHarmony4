%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnPhotoPopup(outputBasePath, annotation, varargin)
%  Runs Derek's code (photopopup) on an image. Saves all the results in a .mat file.
% 
% Input parameters:
%
%   - varargin: Possible values:
%     - 'Relabel': 
%       - 0 will go over each image, and display a blue line if
%         it was already labeled. The user can then re-label the horizon.
%       - 1 (default) will skip already-labeled images, and will reuse
%         partial results for popup, if present
%     - 'AppOnly':
%       - 0 (default) will run the entire thing
%       - 1 will run only the automatic photo-popup
%        
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = dbFnPhotoPopup(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialization
tic;
res = 0;

% check if the user specified the option to relabel
defaultArgs = struct('Recompute', 1, 'ImagesPath', [], 'SuperpixelsOnly', 0, 'MaxImageSize', 800, ...
    'Classifiers', [], 'ClassifierName', [], 'SegmentExec', []);
args = parseargs(defaultArgs, varargin{:});

if ~isfield(annotation, 'folder')
    annotation.folder = annotation.image.folder;
    annotation.filename = annotation.image.filename;
end

imgPath = fullfile(args.ImagesPath, annotation.folder, annotation.filename);
xmlPath = fullfile(outputBasePath, annotation.folder, strrep(annotation.filename, '.jpg', '.xml'));

if exist(xmlPath, 'file')
    imgInfoPopup = loadXML(xmlPath);
end

if ~args.Recompute
    if isfield(imgInfoPopup, 'popup')
        % we're done.
        fprintf('Results already generated. Skipping...\n');
        return;
    end
end

% read the image if it wasn't read
img = imread(imgPath);

% subsample by half, and resize the image if still too big
img = imresize(img, 0.5);
[h,w,c] = size(img);
if h > args.MaxImageSize || w > args.MaxImageSize
    img = imresize(img, args.MaxImageSize/max(h,w), 'bilinear');
end

[segStruct, cimages, cnames] = geometricContextFromImage(img, tmpOutputDir, ...
    'SuperpixelsOnly', args.SuperpixelsOnly, 'Classifiers', args.Classifiers, ...
    'SegmentExec', args.SegmentExec);

[path,baseImgFilename] = fileparts(annotation.filename);

if args.SuperpixelsOnly
    % save it to file
    imgInfoPopup.superpixel.filename = fullfile('segments', sprintf('%s_sp.mat', baseImgFilename));
    save(fullfile(outputBasePath, annotation.folder, 'segments', sprintf('%s_sp.mat', baseImgFilename)), 'segStruct');

    % Save the xml file and we're done!
    fprintf('Saving superpixels results only: %s\n', xmlPath);
    writeXML(xmlPath, imgInfoPopup);
    return;
end

%% Extract the geometry information
% create the directory for the output
popupDir = sprintf('%s/%s/popup/', outputBasePath, annotation.folder);
[s,m,m] = mkdir(popupDir); %#ok

% convert to single-precision to save memory
cimages = single(cimages);
fprintf('done.\n');

% save the raw data
save(fullfile(popupDir, sprintf('%s.mat', baseImgFilename)), 'cnames', 'cimages');

% save info to xml
imgInfoPopup.popup.filename = sprintf('./%s/%s.mat', 'popup', baseImgFilename);
imgInfoPopup.popup.classifierFile = args.ClassifierName;
imgInfoPopup.popup.size.width = size(img, 2);
imgInfoPopup.popup.size.height = size(img, 1);
imgInfoPopup.file.folder = annotation.folder;
imgInfoPopup.file.filename = sprintf('%s.xml', baseImgFilename);

% Save the xml file and we're done!
fprintf('Saving xml file: %s \n', xmlPath);
writeXML(xmlPath, imgInfoPopup);

fprintf('done in %.2fs for a %dx%d image.\n', toc, size(img, 2), size(img, 1));


%% Old code
% % compute geometry labels and confidences
% [labels, conf_map] = APPtestImage(img, segStruct, vert_classifier, horz_classifier, segment_density);
% 
% % convert the output of the classifiers to confidence
% [cimages, cnames] = APPclassifierOutput2confidenceImages(segStruct, conf_map); %#ok
% 
% % save only the labeled image
% limage = APPgetLabeledImage(img, segStruct, labels.vert_labels, labels.vert_conf, labels.horz_labels, labels.horz_conf);
% imwrite(limage, fullfile(popupDir, sprintf('%s.l.jpg', baseImgFilename)));

% % save the raw data for later use
% save(fullfile(popupDir, sprintf('%s.mat', baseImgFilename)), 'cnames', 'cimages', 'labels', 'conf_map');

% imshow(limage);
% pause;
