function h = hashKey(varargin)
% Generates a hash key from the input
%
%   h = hashKey(input)
%
% 'input' can be a cell array, numeric, logical, or string data type.
%
% See also:
%   getDataFromRenderingCache
%
% ----------
% Jean-Francois Lalonde

if nargin > 1
    allKeys = cell(1, nargin);
    for i_arg = 1:nargin
        allKeys{i_arg} = hashKey(varargin{i_arg});
    end
    h = hashKey(strcat(allKeys{:}));
    return;
end

input = varargin{1};

if iscell(input)
    % we're dealing with a cell array
    % this may be big, so we'll first convert to string, then hash
    s = cellfun(@hashKey, input, 'UniformOutput', false);
    h = hashKey(cat(2, s{:}));
    
elseif isnumeric(input) || ischar(input)
    % run hash function directly
    h = CalcMD5(input);
    
elseif islogical(input)
    h = CalcMD5(double(input));
    
elseif isstruct(input)
    if isempty(input)
        % Empty struct
        h = hashKey('empty.struct');
        
    elseif isfield(input, 'hashKey') && ~isempty(input.hashKey)
        % Check if there's already a hash key in there
        h = input.hashKey;
        
    else
        % Recurse
        input = orderfields(input); % make field-order invariant
        h = hashKey({struct2cell(input), fieldnames(input)});
    end
    
elseif isa(input, 'containers.Map')
    h = hashKey(values(input));
    
elseif isa(input, 'EnvironmentMap') 
    h = hashKey({input.data, char(input.format)});
        
else
    % at this point, we don't support anything else
    error('Unsupported hash key type');
end
