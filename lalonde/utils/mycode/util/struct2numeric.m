function s = struct2numeric(s)
% Converts all string fields in a struct to numeric values (when possible)
%
% ----------
% Jean-Francois Lalonde
    
for i_array = 1:numel(s)
    % get field names
    fNames = fieldnames(s(i_array));
    
    for i_field = 1:length(fNames)
        curField = fNames{i_field};
        if isstruct(s(i_array).(curField))
            s(i_array).(curField) = struct2numeric(s(i_array).(curField));
        else
            % try converting to numeric
            if ischar(s(i_array).(curField))
                n = str2double(s(i_array).(curField));
                if ~isnan(n)
                    % this worked!
                    s(i_array).(curField) = n;
                else
                    % check if the string is 'NaN'
                    if strcmp(s(i_array).(curField), 'NaN')
                        s(i_array).(curField) = NaN;
                    end
                end
            end
        end
    end
end
