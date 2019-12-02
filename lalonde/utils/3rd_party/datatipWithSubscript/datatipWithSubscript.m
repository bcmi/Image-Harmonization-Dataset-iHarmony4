function output_txt = datatipWithSubscript(obj,event_obj)
% Display the position of the data cursor with index/subscript information
%
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).
%
% A simple datatip text update function that additionally displays the
% linear index or the subscripts of an object's selected point.

pos = get(event_obj,'Position');
output_txt = {['X: ',num2str(pos(1),4)],...
              ['Y: ',num2str(pos(2),4)]};

% If there is a Z-coordinate in the position, display it as well. Also get
% the size of the object.
if length(pos) > 2
    output_txt{end+1} = ['Z: ',num2str(pos(3),4)];
    dataSize  = size(get(get(event_obj,'Target'),'ZData'));
else
    dataSize  = size(get(get(event_obj,'Target'),'YData'));
end

% Get the linear index
dataIndex = get(event_obj,'DataIndex');

if sum(dataSize>1)>1
    % display subscripts for data with more than 1 dimension
    S = cell(1,numel(dataSize));
    [S{:}] = ind2sub(dataSize,dataIndex);
    subsString = sprintf('%i,',cell2mat(S));
    output_txt{end+1} = ['@ (', subsString(1:end-1), ')'];
else
    % display linear index for vector data
    output_txt{end+1} = ['@ ',num2str(dataIndex)];
end
