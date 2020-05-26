%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnCompileMatchingResults
%   Scripts that compiles the matching results, accumulated over several images. New and improved
%   version.
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r=dbFnCompileMatchingResults(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize
r=0;
global scores1stOrder scores2ndOrder processDatabaseImgNumber;

% read arguments
defaultArgs = struct('ColorSpaces', [], 'Techniques', [], 'Distances', [], 'Eval', []);
args = parseargs(defaultArgs, varargin{:});

n = processDatabaseImgNumber;

for e=1:length(args.Eval)
    for c=1:size(args.ColorSpaces,1)
        color = args.ColorSpaces{c,2};

        for t=1:length(args.Techniques)
            for d=1:length(args.Distances)
                matchingName = args.Techniques{t};

                % joint
                try
                    % use the second order to store the joint
                    scores2ndOrder(e,c,n,t,d) = str2double(annotation.(args.Eval{e})(color).(matchingName).joint.(args.Distances{d}));
                catch
                    scores2ndOrder(e,c,n,t,d) = -1;
                end

                % marginals
                try
                    dist1stVec = zeros(1,3);
                    for k=1:3
                        dist1stVec(k) = str2double(annotation.(args.Eval{e})(color).(matchingName).marginal(k).(args.Distances{d}));
                    end
                    scores1stOrder(e,c,n,t,d) = mean(dist1stVec);
                catch
                    scores1stOrder(e,c,n,t,d) = -1;
                end
            end
        end
    end
end