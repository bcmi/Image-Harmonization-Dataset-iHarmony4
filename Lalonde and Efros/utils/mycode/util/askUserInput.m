%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [uInput, uDescription, xUsr, yUsr] = askUserInput(figureHandle, question, options)
%  Ask the user to choose one from several options, or click at a location on the figure. This
%  function waits until the user has selected a valid option to exit.
% 
% Input parameters:
%   - figureHandle: handle to the figure to use for user input
%   - question: question to ask the user at the beginning
%   - options: the different options to ask the user. e.g. {{'j', 'jeff'}, {'b', 'barbara'}}
%
% Output parameters:
%   - uInput: input key (or mouse button) pressed by the user
%   - uDescription: description corresponding to the user input.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [uInput, uDescription, xUsr, yUsr] = askUserInput(figureHandle, question, options, fullcross) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 3
    fullcross = 0;
end

% Bring the figure to the foreground
figure(figureHandle);

% Loop forever (until we get a valid answer)
while 1
    % Ask the question
    fprintf('%s\n', question);

    % Show the possible answers
    if ~isempty(options)
        fprintf('Possible options are: \n');
        for i=1:length(options)
            fprintf('\t ''%s'': %s\n', options{i}{1}, options{i}{2});
        end
    end

    % Wait for user input
    % [xUsr,yUsr,button] = ginput(1);
    xUsr = 0; yUsr = 0;
    
    % build a stupid crosshair because the default one varies
    p = zeros(16,16); p(1:end-1,8) = 1; p(8,1:end-1) = 1; p(p==0) = NaN;
    
    % setup crosshair
    figure(figureHandle);
    prevPointer = get(figureHandle, 'Pointer');
    if fullcross
        set(figureHandle, 'Pointer', 'fullcross');
    else
        set(figureHandle, 'Pointer', 'custom');
        set(figureHandle, 'PointerShapeCData', p); set(figureHandle, 'PointerShapeHotSpot', [8 8]);
    end
    pressedId = waitforbuttonpress;
    set(figureHandle, 'Pointer', prevPointer);
    
    if ~pressedId
        % mouse click
        button = get(figureHandle, 'SelectionType');
        pt = get(gca(figureHandle), 'CurrentPoint');
        xUsr = pt(1,1); yUsr = pt(1,2);

        switch button
            case 'normal'
                uInput = 1; uDescription = 'Left-button mouse';
                return;
            case 'shift'
                uInput = 2; uDescription = 'Right-button mouse';
                return;
            case 'extend'
                uInput = 3; uDescription = 'Middle-button mouse';
                return;
            case 'open'
                uInput = 4; uDescription = 'Double click';
                return;
            otherwise
                error('Unsupported button!');
        end
    else
        % key press
        curChar = get(figureHandle, 'CurrentCharacter');
        for i=1:length(options)
            if strcmp(curChar, options{i}{1})
                uInput = curChar;
                uDescription = options{i}{2};
                return;
            end
        end
        fprintf('Invalid option! Try again...\n\n');
    end
end
