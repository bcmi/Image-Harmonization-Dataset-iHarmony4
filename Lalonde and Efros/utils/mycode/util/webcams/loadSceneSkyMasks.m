%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [skyMask, sceneMask, groundMask, verticalMask] = loadSceneSkyMasks(skyMaskPath, seqInfo)
%  Useful function which loads the sky and scene masks for a given
%  image sequence.
% 
% Input parameters:
%  - skyMaskPath: path to the sky (and scene) masks
%  - seqInfo: sequence information
%  - varargin
%    - 'Automatic': [0]=use the manually labelled masks, 1=use the
%    automatically estimated sky masks (using geometric context). This
%    will return only skyMask (will throw an error otherwise)
%    - 'DbPath': path to the subSequenceDb
%
% Output parameters:
%  - skyMask: the sky mask (1=sky, 0=non-sky)
%  - sceneMask: (optional) the scene mask (1=scene, 0=non-scene)
%  - groundMask: (optional) the ground mask (1=ground, 0=non-ground)
%  - verticalMask: (optional) the vertical mask (1=vertical, 0=non-vertical)
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [skyMask, sceneMask, groundMask, verticalMask] = loadSceneSkyMasks(skyMaskPath, seqInfo, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

defaultArgs = struct('DbPath', [], 'Automatic', 0, 'LoadWarpMask', 0, 'Matte', 0);
args = parseargs(defaultArgs, varargin{:});

if args.Automatic
    if nargout > 1
        error('The automatic option only returns 1 argument!');
    end
    
    % load automatically-computed sky mask
    geomContextData = load(fullfile(args.DbPath, seqInfo.geomContext.filename));
%     skyMask = geomContextData.geomContext(:,:,3) > 0.3;
    
    [m,mind] = max(geomContextData.geomContext, [], 3);
    skyMask = imclose(mind==3, strel('disk', 2));
    
    skyMask = imresize(skyMask, [str2double(seqInfo.sequence.frameSize.height) str2double(seqInfo.sequence.frameSize.width)], 'nearest');
    
else
    % load manually-labelled sky mask
    skyMask = im2double(imread((fullfile(skyMaskPath, seqInfo.skyMask.filename))));
    if ~args.Matte
        skyMask = skyMask > 0.5;
    end
    skyMask = skyMask(:,:,1);

    % make sure the horizon lies below all sky pixels
    if isfield(seqInfo, 'horizon')
        horizon = str2double(seqInfo.horizon.frac);
        [row,col] = find(skyMask); %#ok
        skyMask(row(row >= horizon.*size(skyMask,1)),:) = 0;
    end
    
    if args.LoadWarpMask
        warpMask = loadWarpMask(args.DbPath, seqInfo);
        skyMask = skyMask & warpMask;
    end

    if nargout > 1
        if isfield(seqInfo, 'sceneMask')
            sceneMaskPath = fullfile(skyMaskPath, seqInfo.sceneMask.filename);
        else
            sceneMaskPath = fullfile(skyMaskPath, strrep(seqInfo.skyMask.filename, 'mask', 'scene'));
        end
        sceneMask = im2double(imread(sceneMaskPath)) > 0.5;
        sceneMask = sceneMask(:,:,1) & ~skyMask;
        
        if args.LoadWarpMask
            sceneMask = sceneMask & warpMask;
        end
    end

    if nargout > 2
        groundMask = im2double(imread(fullfile(skyMaskPath, seqInfo.groundMask.filename))) > 0.5;
        groundMask = groundMask(:,:,1) & sceneMask;
            
        if args.LoadWarpMask
            groundMask = groundMask & warpMask;
        end
    end

    if nargout > 3
        verticalMask = sceneMask & ~groundMask;
    end
end

function warpMask = loadWarpMask(dbPath, seqInfo)

if isfield(seqInfo.averageImg, 'mask')
    warpMask = im2double(imread((fullfile(dbPath, seqInfo.averageImg.mask.filename)))) > 0.9;
else
    warpMask = true(str2double(seqInfo.sequence.frameSize.height), str2double(seqInfo.sequence.frameSize.width));
end
