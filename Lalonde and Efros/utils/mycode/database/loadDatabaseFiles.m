%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function db = loadDatabaseFast(databasePath, files, directories) 
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
function db = loadDatabaseFiles(databasePath, files, directories) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N = length(files);

% Pre-initialize the database
db = repmat(struct('document', []), 1, N);

ind = floor((0.01:0.01:1) .* N);
p=progressbar();
p = setMessage(p, 'Loading documents...');
for j=1:N
    if intersect(j, ind)
        p = setStatus(p, j/N);
        display(p);
    end

    % read the structure from the file (~10X faster to use labelme's function than anything that
    % uses the matlab xml API)
    xmlPath = fullfile(databasePath, directories{j}, files{j});
%     s = loadXML(xmlPath);
    s = load_xml(xmlPath);
    
    if isfield(s, 'document')
        db(j).document = s.document;
    else
        % append it to the database, and increment the instance counter
        db(j).document = s;
    end
end
% fprintf(']\n');

