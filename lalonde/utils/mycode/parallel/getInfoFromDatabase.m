function [dbInfo, dbId] = getInfoFromDatabase(db, varargin)
% Database retrieval helper.
%
%   [imgInfo, imgId] = getInfoFromDatabase(sceneDb, sceneId, imageId)
%
%   [...] = getInfoFromDatabase(imageDb, imageId)
%
%   [...] = getInfoFromDatabase(imageDb, filename)
%
%   [lightInfo, lightId] = getInfoFromDatabase(lightDb, lightId);
%
% ----------
% Jean-Francois Lalonde

dbType = getDatabaseType(db);

switch dbType
    case 'scene'
        % we have a sceneDb:
        sceneId = varargin{1};
        dbId = varargin{2};
        
        dbInfo = db.scene(sceneId).image(dbId);
        
    case 'light'
        dbInfo = db.light(varargin{1});
        dbId = varargin{1};
        
    case 'lightModel'
        dbInfo = db.lightModel(varargin{1});
        dbInfo.type = db.type;
        dbId = varargin{1};
        
    case 'image'
        % we have an imageDb
        if ischar(varargin{1})
            imageNames = arrayfun(@(i) i.file.jpg, db.image, 'UniformOutput', false);
            [~,f] = cellfun(@(n) fileparts(n), imageNames, 'UniformOutput', false);
            
            dbId = find(strcmpi(f, varargin{1}));
            assert(~isempty(dbId), 'Could not find image in database');
            dbInfo = db.image(dbId);
        else
            dbId = varargin{1};
            dbInfo = db.image(dbId);
        end
        
    case 'model'
        dbId = varargin{1};
        dbInfo = db.model(dbId);
        
    case 'face'
        dbInfo = db.face(varargin{1});
        dbId = varargin{1};
        
        % copy the other fields
        f = fieldnames(db);
        f(cellfun(@(s) strcmpi(s, 'face'), f)) = [];
        for i_f = 1:length(f)
            dbInfo.db.(f{i_f}) = db.(f{i_f});
        end
        
    case 'generic'
        dbInfo = db.generic(varargin{1});
        dbId = varargin{1};
        db.path = [];
        
    otherwise
        error('Unsupported input database of type %s.', dbType);
end

% concatenate the path to the database!
dbInfo.db.path = db.path;