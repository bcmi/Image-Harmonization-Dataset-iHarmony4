function db = getDatabaseSubset(db, ind, varargin)
% Helper to get only a subset of a database. 
% 
%   db = getDatabaseSubset(db, ind)
% 
% See also:
%   getDatabaseType
%
% ---------- 
% Jean-Francois Lalonde

nohash = false;

parseVarargin(varargin{:});

if isa(db, 'containers.Map')
    % we've got a map. do this for all databases in there.
    keyNames = keys(db);
    dbTmp = containers.Map;
    
    for i_key = 1:length(keyNames)
        dbTmp(keyNames{i_key}) = ...
            getDatabaseSubset(db(keyNames{i_key}), ind, varargin{:});
    end
    db = dbTmp;
    return;
end

dbType = getDatabaseType(db);
db.(dbType) = db.(dbType)(ind);

hasHash = isfield(db, 'hashKey');
if hasHash
    % remove the hashKey
    db = rmfield(db, 'hashKey');
end
    
if hasHash && ~nohash
    % replace the hashKey
    db.hashKey = hashKey(db);
end
