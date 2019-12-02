%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function db = loadDatabase(databasePath, subDirectories)
%   Loads a database by reading several xml files. 
% 
% Input parameters:
%   - databasePath: path to the database
%   - subDirectories: cell array of subdirectories to process
%
% Output parameters:
%
% Warning:
%   Assumes that the databasePath follows pretty much the same structure as the labelme database.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function db = loadDatabase(databasePath, subDirectories) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[files, directories] = getFilesFromSubdirectories(databasePath, subDirectories, 'xml');
N = length(files);

% Pre-initialize the database
db = repmat(struct('document', []), 1, N);

ind =  floor((0.05:0.05:1) .* N);
fprintf('[');
for j=1:N
    if intersect(j, ind)
        fprintf('%%');
    end
    
    % read the structure from the file (~10X faster to use labelme's function than anything that
    % uses the matlab xml API)
    xmlPath = fullfile(databasePath, directories{j}, files{j});
    s = readStructFromXML(xmlPath);

    % append it to the database, and increment the instance counter
    db(j).document = s;
end
fprintf(']\n');

return;

% number of instances created in the database
nbInstances = 1;
db = [];

% loop over all the subdirectories
for i=1:length(subDirectories)
    fprintf(1, 'Reading images from %s: ', subDirectories{i});
    totalDir = fullfile(databasePath, subDirectories{i});
    
    % read all the xml files in the subdirectory
    files = dir([totalDir '/*.xml']);
    
    % loop over all the files
    N = size(files,1);
    prev = 0;
    fprintf('[');
    for j=1:N
        if mod(j,10) == 0
            fseek(1, -5, 'cof');
            cur = floor(j/N*100/2);
            fprintf('%s', repmat('%', 1, cur-prev));
            prev = cur;
        end
        
        % read the structure from the file (way faster to use labelme's function than anything that
        % uses the matlab xml API)
        s = readStructFromXML([totalDir '/' files(j).name]);
        
        % append it to the database, and increment the instance counter
        db(nbInstances).document = s;
        nbInstances = nbInstances + 1;
    end
    fprintf('%s]\n', repmat('%', 1, 50-prev));
end
