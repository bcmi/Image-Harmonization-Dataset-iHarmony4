%% these will be the second-level keywords
function keyword = filterKeyword(name)
if ~containsOR(name, 'part', 'occlude', 'region', 'crop', 'lowres', 'croip', 'cop', 'wheel', 'trunc')
    % filter all the pascal keywords
    if startswith(name, 'pas')
        keyword = '';
    % filter persons
    elseif containsOR(name, 'person', 'man', 'woman', 'pedestrian', 'people') && ~containsAND(name, 'man', 'hole') && ~containsOR(name, 'upperbody')
        keyword = 'person';
    elseif contains(name, 'car')
        keyword = 'car';
    elseif strcmp(name, 'car') || startswith(name, 'car ') && ...
            ~containsOR(name, 'entrance', 'wheel', 'door', 'window')
        keyword = 'car';
    elseif contains(name, 'motorbike') || contains(name, 'motorcycle')
        keyword = 'motorcycle';
    elseif startswith(name, 'sky') && ~contains(name, 'scraper')
        keyword = 'sky';
    elseif contains(name, 'building') || contains(name, 'scraper')
        keyword = 'building';
    elseif startswith(name, 'tree')
        keyword = 'tree';
    elseif contains(name, 'flower')
        keyword = 'flower';
    elseif contains(name, 'plant')
        keyword = 'plant';
    elseif startswith(name, 'trash')
        keyword = 'trash';
    elseif containsAND(name, 'man', 'hole')
        keyword = 'manhole';
    elseif containsOR(name, 'truck', 'truc')
        keyword = 'truck';
    elseif startswith(name, 'tree') || startswith(name, 'palmtree')
        keyword = 'tree';
    elseif startswith(name, 'bush')
        keyword = 'bush';
    elseif startswith(name, 'car')
        keyword = 'car';
    elseif startswith(name, 'snow')
        keyword = 'snow';
    elseif contains(name, 'water') || startswith(name, 'sea')
        keyword = 'water';
    elseif contains(name, 'sand')
        keyword = 'sand';
    elseif contains(name, 'rock')
        keyword = 'rock';
    elseif containsOR(name, 'road', 'street')
        keyword = 'road';
    elseif contains(name, 'mountain')
        keyword = 'mountain';
    elseif contains(name, 'animal')
        keyword = 'animal';
    elseif startswith(name, 'lion')
        keyword = 'lion';
    elseif contains(name, 'house')
        keyword = 'house';
    elseif contains(name, 'horse')
        keyword = 'horse';
    elseif contains(name, 'foliage')
        keyword = 'foliage';
    elseif contains(name, 'field')
        keyword = 'field';
    else
        % flush this object
        keyword = '';
    end
else
    keyword = '';
end

%% Auxilliary Functions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c = contains(str, substr)
c = ~isempty(strfind(str, substr));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c = containsOR(str, varargin)
c = 0;
for k = 1:numel(varargin)
    if contains(str, varargin{k})
        c = 1;
        return;
    end
end

function c = containsAND(src, varargin)
c = 1;
for k = 1:numel(varargin)
    c = c & contains(src, varargin{k});
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = startswith(str, substr)

s = strcmp(str(1:min(numel(str), numel(substr))), substr);
