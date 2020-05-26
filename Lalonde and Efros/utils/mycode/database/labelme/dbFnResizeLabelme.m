%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnResizeLabelme(outputBasePath, annotation, varargin)
%   Resizes a single image to a maximum size of 800x800 and update the annotations
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res=dbFnResizeLabelme(outputBasePath, annotation, varargin)
res = 0;

%% Check if the user specified the option to recompute
defaultArgs = struct('Recompute', 0, 'ImagesPath', [], 'NewMaxSize', 800);
args = parseargs(defaultArgs, varargin{:});

% check if the new image already exists
newImgPath = fullfile(outputBasePath, 'Images', annotation.folder);
[x,m,m] = mkdir(newImgPath);
newImgName = fullfile(newImgPath, annotation.filename);
newAnnotationPath = fullfile(outputBasePath, 'Annotation', annotation.folder);
newAnnotationName = fullfile(newAnnotationPath, strrep(annotation.filename,'.jpg','.xml'));
[x,m,m] = mkdir(newAnnotationPath);

%% Make sure we do need to resize the image
if ~args.Recompute
    if exist(newImgName, 'file') && exist(newAnnotationName, 'file')
        % don't resize unless the annotations changed (number of
        % annotations)
        existingAnnotation = load_xml(newAnnotationName);
        
        if isfield(existingAnnotation.annotation, 'object') && isfield(annotation, 'object')
            if size(existingAnnotation.annotation.object) == size(annotation.object)
                % both annotations have the same number of object. No change, therefore do not
                % recompute.
                fprintf('Information already computed. Skipping this image.\n');
                return;
            end
        else
            fprintf('Annotation contains no object. Skipping. \n');
            return;
        end

        % In any other cases, we need to resize because there's no updated information
    end
end
%% Ok, then. Let's resize the image and save it to the new directory
% read the image 
img = imread(fullfile(args.ImagesPath, annotation.folder, annotation.filename));
[h,w,c] = size(img);

scaling = min(args.NewMaxSize / max(h,w), 1);

% cook up the new image (and corresponding annotation) to the right size 
if scaling < 1
    [newannotation, newimg] = LMimscale(annotation, img, scaling, 'bilinear');
else
    newannotation = annotation; 
    newimg = img;
end

% write new image
imwrite(newimg, newImgName, 'jpg', 'quality', 100);

% write new annotation file; don't put tags in attributes.
useAttribs = 0;
v.annotation = newannotation;
write_xml(newAnnotationName, v, useAttribs);
