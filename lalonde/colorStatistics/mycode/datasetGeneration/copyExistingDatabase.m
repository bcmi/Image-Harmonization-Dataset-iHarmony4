function copyExistingDatabase 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath ../xml;
addpath ../../3rd_party/LabelMeToolbox;

dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/smallDataset/testData/';
outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/testData/temp/';
annotationPath = '/nfs/hn21/projects/labelme/Annotation/';

% loop over all the subdirectories
totalDir = fullfile(dbPath, 'spatial_envelope_256x256_static_8outdoorcategories');

% read all the xml files in the subdirectory
files = dir([totalDir '/*generated.xml']);

% object to paste must occupy between 5% and 60% of the image
minArea = 256*256*0.05;
maxArea = 256*256*0.6;

N = size(files,1);

imgNb = 1943;
% loop over all the files
for j=1:N
    fprintf('%d.',j);
    [pathstr,name,ext,versn] = fileparts(files(j).name);

    % read the structure from the file
    s = readStructFromXML(fullfile(totalDir, files(j).name));


    % retrieve the original image from the labelme database
    [pathstr,name,ext,versn] = fileparts(s.image.filename);
    LMannotationPath = strrep(fullfile(annotationPath, s.image.folder, sprintf('%s.xml', name)), '_generated', '');
    a = loadXML(LMannotationPath);
    annotation = a.annotation;

    isOk = 0;
    if isfield(annotation, 'object')
        indRand = randperm(length(annotation.object));
        for i=indRand
            [xPoly, yPoly] = getLMpolygon(annotation.object(i).polygon);
            objPoly = [xPoly yPoly]';

            areaObj = nnz(poly2mask(objPoly(1,:), objPoly(2,:), 256, 256));
            if areaObj > minArea && areaObj < maxArea
                % select the object index for generating the test image
                isOk = 1;
                indObjOriginal = i;
                break;
            end
        end
    end

    if isOk
        imgName = sprintf('img_%04d_generated.jpg', imgNb);

        % there's a label. Prepare new xml
        s.image.originalFolder = s.image.folder;
        s.image.originalFilename = strrep(sprintf('%s%s', name, ext), '_generated', '');
        s.image.folder = 'images';
        s.image.filename = imgName;

        % copy image
        srcImg = fullfile(dbPath, s.image.originalFolder, 'images', sprintf('%s%s', name, ext));
        dstImg = fullfile(outputBasePath, s.image.folder, s.image.filename);

        % write new xml
        xmlPath = fullfile(outputBasePath, sprintf('img_%04d_generated.xml', imgNb));

        if isfield(s, 'class')
            % do it!
            copyfile(srcImg, dstImg);
            writeStructToXML(s, xmlPath);
        end

        imgName = sprintf('img_%04d.jpg', imgNb);

        % there's a label. Prepare new xml
        s.image.folder = 'images';
        s.image.filename = imgName;
        s.object = annotation.object(indObjOriginal);
        % remove the label
        if isfield(s, 'class')
            s = rmfield(s, 'class');
            s.image.generated = 0;
        end

        % copy image
        srcImg = fullfile(dbPath, s.image.originalFolder, 'images', s.image.originalFilename);
        dstImg = fullfile(outputBasePath, s.image.folder, s.image.filename);

        % write new xml
        xmlPath = fullfile(outputBasePath, sprintf('img_%04d.xml', imgNb));

        % do it!
        copyfile(srcImg, dstImg);
        writeStructToXML(s, xmlPath);

        imgNb = imgNb + 1;
    else
        fprintf('Labeled image does not contain an object of sufficient size, skipping...\n');
    end
end



