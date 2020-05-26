function type = getDatabaseType(db)
% Returns the type of database this is. 
%
%   type = getDatabaseType(db)
%
% Possible return values are:
%   - 'light'
%   - 'image'
%   - 'scene'
%   - 'model'
% 
% ----------
% Jean-Francois Lalonde

fNames = fieldnames(db);

for i_struct = 1:length(fNames)
    switch fNames{i_struct}
        case {'light', 'image', 'scene', 'model', 'lightModel', ...
                'face', 'generic', 'results'} 
            type = fNames{i_struct};
            return;
            
    end
end

error('getDatabaseType:nodb', 'Could not find database type');

