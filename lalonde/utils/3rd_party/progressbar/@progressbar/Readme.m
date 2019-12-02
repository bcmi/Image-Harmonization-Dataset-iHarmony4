% Put the directory @progressbar to your path

% Initialize the progressbar
p=progressbar();

% To draw the progress bar simply write the following command,
% where progress is a number between 0 and 1 denoting the 
% percentage of completion
p=setStatus(p,progress)


% If you have to do some iterative caculations, where each iteration
% needs the same amount of time, you could use the progress bar as follows
progress=0;
p=progressbar();

for k=1:NumberOfIterations

    % Perform some calculations here
    
    progress = progress + 1 / NumberOfIterations;
    p=setStatus(p,progress)
end