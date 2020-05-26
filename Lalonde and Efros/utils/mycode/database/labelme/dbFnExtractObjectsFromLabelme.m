%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnExtractObjectsFromLabelme(outputBasePath, annotation, varargin)
%  Extracts all the objects segmented from the images.
% 
% Input parameters:
%
%   - varargin: Possible values:
%     - 'Relabel': 
%       - 0 will go over each image, and display a blue line if
%         it was already labeled. The user can then re-label the horizon.
%       - 1 (default) will skip already-labeled images
%        
% Output parameters:
%   
%
% Notes:
%   - Uses the writeXML function from the labelme toolbox because it enables faster reading
%     of input files
%   - Does not extract deleted objects (as of 02/28/07)
%   - Because it does not extract deleted objects, it doesn't support the Recompute option anymore.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [r,filenames]=dbFnExtractObjectsFromLabelme(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r=0;
filenames=[];
% check if the user specified the option to relabel
defaultArgs = struct('ImagesPath', [], 'HighResImagesPath', [], 'ImgInfo', [], 'Recompute', 0);
args = parseargs(defaultArgs, varargin{:});

% build the xml path
xmlBasePath = fullfile(outputBasePath, annotation.folder);
[d,d,d] = mkdir(xmlBasePath); %#ok
setPermissions(xmlBasePath);

[p, xmlBaseFile] = fileparts(annotation.filename);
xmlBaseFile = fullfile(xmlBasePath, xmlBaseFile);

% delete whatever files were already computed for that image
existingFiles = dir(sprintf('%s_*', xmlBaseFile));
for i=1:length(existingFiles)
    delete(fullfile(xmlBasePath, existingFiles(i).name));
end
    
if ~isfield(annotation, 'object')
    fprintf('No objects found! Skipping...\n');
    return;
end

objInfoBase.image = args.ImgInfo.image;

deleted = logical(arrayfun(@(x) str2double(x), [annotation.object.deleted]));
nbObjects = nnz(~deleted);

if nbObjects == 0
    fprintf('All objects deleted! Skipping...\n');
    return;
end

notDeleted = find(~deleted);
filenames = cell(length(notDeleted),1);

i=1;
for j=notDeleted;
    xmlPath = sprintf('%s_%04d.xml', xmlBaseFile, j);
    [path, xmlName] = fileparts(xmlPath);
    
    objInfo = objInfoBase; 
    objInfo.file.filename = sprintf('%s.xml', xmlName);
    objInfo.file.folder = annotation.folder;
    
    filenames{i} = objInfo.file.filename;
    
    % copy each object information into a new xml structure
    objInfo.object = annotation.object(j);
    objInfo.object.objectId = j;

    % make sure the object has a name!
    if ~isfield(objInfo.object, 'name')
        objInfo.object.name = 'no-name';
    end

    % save the file (overwrite); use attributes.
    %fprintf('Saving xml file: %s\n', xmlPath);
    write_xml(xmlPath, objInfo, 1);
    i = i+1;
end


