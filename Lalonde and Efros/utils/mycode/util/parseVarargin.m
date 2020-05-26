function parseVarargin(varargin)
% Parse the list of "extra" arguments in pairs, resetting any valid variables
%
%   parseVarargin(<Name1, Val1>, <Name2, Val2>, ..., <NameN, ValN>);
%
% Usage:
% 
%   % declare list of variables and their defaults values
%   var1 = 1;
%   var2 = 'hello';
%
%   % parse input arguments
%   parseVarargin(varargin{:});
%
%   % var1 and var2 now have the updated value passed in as (optional)
%   % argument
%
% It is possible to get the list of optional argument to a function which
% uses parseVarargin by calling that function with a single argument
% 'help'. For example, suppose we want to know what the optional arguments
% of the function myFun, we simply call it:
%
%   myFun('help')
%
% This will return a list of possible optional arguments. 
%
% TODO: 
%   Fix problem when passing 'help' to a class member function... sets
%   default first argument to the object itself. e.g.: m.function('help')
%
% ----------
% Jean-Francois Lalonde

helpStr = 'help';

narginCaller = evalin('caller', 'nargin');
if narginCaller == 1
    % There does not appear to be a way to retrieve the name of the caller's 
    % first input argument. So loop over all available variables, and check
    % if one is exactly 'help'. If so, display this. Otherwise, keep going.
        
    % Display list of possible arguments and their types
    args = evalin('caller', 'whos');
    helpMode = false;
    for i_arg=1:length(args)
        if strcmp(args(i_arg).class, 'char')
            % we found a string. Check if it corresponds to 'helpStr'
            val = evalin('caller', args(i_arg).name);
            if strcmpi(val, helpStr)
                helpMode = true;
                
                % remove the current argument from the list (we know it's
                % not an optional argument!)
                args(i_arg) = [];
                break;
            end
        end
    end
    
    if helpMode
        % TODO: parse the file and automatically retrieve the comments directly
        % above the line where the argument is declared. Output it below.
        fprintf('Possible optional arguments: \n');
        for i_arg=1:length(args)
            % ignore 'varargin' and 'ans'
            if ~strcmp(args(i_arg).name, 'varargin') && ...
                    ~strcmp(args(i_arg).name, 'ans')
                fprintf('  %s (%s)\n', args(i_arg).name, args(i_arg).class);
            end
        end
        
        error('parseVarargin:displayArgs', ...
            ['Call function again with valid parameters.' ...
            '\n (this error is normal -- blame Matlab''s inability to stop execution cleanly.)']);
    end
end

for i = 1:2:length(varargin)
    if ~(evalin('caller', sprintf('exist(''%s'')', varargin{i}))==1)
        error('Parameter "%s" not recognized.', varargin{i});
    end
    assignin('caller', varargin{i}, varargin{i+1});
end
