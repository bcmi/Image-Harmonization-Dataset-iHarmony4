%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [segStruct, cimages, cnames] = geometricContextFromImage(img, tmpOutputDir, varargin)
%  Runs the Geometric Context algorithm on an image. 
% 
% Input parameters:
%  - img: input image
%  - tmpOutputDir: temporary directory to store the segmentation results
%  - varargin:
%    - 'SuperpixelsOnly' [0] or 1: whether to compute the superpixel
%      segmentation only, or the full thing.
%    - 'Classifiers': mat file containing the classifier parameters
%    - 'SegmentExec': executable of the superpixel segmenter.
%
%        
% Output parameters:
%  - segStruct: superpixel segmentation information
%  - cimages: images for each class
%  - cnames: names of each class
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [segStruct, cimages, cnames, imsegs] = geometricContextFromImage(img, tmpOutputDir, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% parse the arguments
defaultArgs = struct('SuperpixelsOnly', 0, 'Classifiers', [], 'SegmentExec', [], 'SegStruct', [], 'ShadowProb', []);
args = parseargs(defaultArgs, varargin{:});

img = im2double(img);


%% Run the superpixel segmentation
if isempty(args.SegStruct)
    % convert to ppm, segment, convert back to pnm
    fprintf('Running superpixel segmentation...');
    sp_sigma = 0.8; sp_k = 100; sp_min = 100;
    
    baseImgFilename = sprintf('%09d', round(1e9*rand));
    outSegDir = tmpOutputDir;
    [s,m,m] = mkdir(outSegDir); %#ok
    baseSegFilename = fullfile(outSegDir, baseImgFilename);
    
    tmpPpm = sprintf('%s_inTmp.ppm', baseSegFilename);
    tmpSegPpm = sprintf('%s_segTmp.ppm', baseSegFilename);
    
    imwrite(img, tmpPpm);
    if ~isdeployed
        system(sprintf('export LD_LIBRARY_PATH=/usr/lib; %s %f %d %d %s %s', args.SegmentExec, sp_sigma, sp_k, sp_min, tmpPpm, tmpSegPpm));
    else
        system(sprintf('setenv LD_LIBRARY_PATH /usr/lib; %s %f %d %d %s %s', args.SegmentExec, sp_sigma, sp_k, sp_min, tmpPpm, tmpSegPpm));
    end
    
    % get the superpixel structure
    segStruct = getSuperPixelFromFile(tmpSegPpm);
    
    % remove the temporary files
    delete(tmpPpm), delete(tmpSegPpm);
    
    if args.SuperpixelsOnly
        % return empty popup results
        cimages = []; cnames = [];
        return;
    end
else
    segStruct = args.SegStruct;
end

%% Extract the geometry information
fprintf('Extracting geometry information...'); 

% Run the geometric context code
[pg, dummy, imsegs] = ijcvTestImage(im2double(img), segStruct(1), args.Classifiers, [], [], [], [], args.ShadowProb);
[cimages, cnames] = pg2confidenceImages(segStruct(1), {pg});
cimages = cimages{1};

fprintf('done.\n');
% We're done!
