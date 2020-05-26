%% Demonstrates usage and behaviour of parseargs
% Use parseargs to simplify the input handling of functions which have
% a lot of options.  Apart from reducing the tedious task of input
% checking, using parseargs helps to make it clear what all the possible
% inputs to a function are, and reduces the chances of breaking a function
% while adding options to it.

%% Create structure X
% The structure has fields chosen to demonstrate the various features of
% parseargs.
X = struct;
X.StartValue = 10; % must be a double scalar
X.StopOnError = false; % must be a logical scalar
X.OutputFile = 'out.txt'; % must be string (of any size)
X.SolverType = {'fixedstep','variablestep'}; % must be one of these strings, and
                                             % will default to 'fixedstep'
X.InputData = [1 2 3 4]; % must be a double (of any size)
X.OutputData = []; % can be anything at all

%% Demonstrate default behaviour
% The only change in the output will be that a default string is selected
% for "SolverType"
Y = parseargs(X)

%% Demonstrate ability to specify other fields
% All fields will take the specified values
Y = parseargs(X,...
    'StartValue',3,...
    'StopOnError',true,...
    'OutputFile','temp.txt',...
    'SolverType','variablestep',...
    'InputData',[6 7],...
    'OutputData',{1 2 3})

%% Demonstrate error thrown when a non-scalar value is specified for a scalar one
try
    Y = parseargs(X,'StartValue',[1 2])
catch
    disp(lasterr);
end

%% Demonstrate error thrown when a different data type is specified
try
    Y = parseargs(X,'StopOnError',int32(1))
catch
    disp(lasterr);
end

%% Demonstrate error thrown when a string is specified which is not one of the allowed values
try
    Y = parseargs(X,'SolverType','ode1')
catch
    disp(lasterr);
end



