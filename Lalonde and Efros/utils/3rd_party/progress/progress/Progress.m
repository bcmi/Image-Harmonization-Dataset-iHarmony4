classdef Progress < handle
    %PROGRESS A Java progress bar
    % The progress bar displays a window containing any number of bars. The
    % bars are organized in a stack, where only the most recent bar can be
    % changed. This allows progress of sub-tasks to be monitored in a natural
    % way.
    %
    % Tasks are timed and the times are used to fit a second order polynomial.
    % This produces expected remaining times which are displayed on the bar.
    % In some cases, this seems broken. Obviously it will also be broken for
    % tasks of complexity not in O(1), O(n) or O(n^2).
    %
    % The most convenient way of using the progess bars is explained below.
    % For an example of manually including the bars in your code, see
    % PROGRESS_EXAMPLE2.
    %
    % There is an annotation system which can be invoked via prog or
    % Progress.annotate. This accepts matlab code with marked for loops and
    % adds the required boilerplate code for a progress bar.
    %
    % for var_name=min:max %%p#
    %   <code>
    % end %%p#
    %
    % is the method of annotation. # indicates a 1-based index for the for
    % loop. Nested for loops should be numbered starting with 1 at the outside
    % and increasing inwards. The end of a for loop must be numbered in the
    % same way. Nested example:
    %
    % for outer_var = min : max %%p1
    %   <some code>
    %   for inner_var = 1:500 %%p2
    %     <more code>
    %   end %%p2
    %   <more code>
    % end %%p1
    %
    % If a for loop should not be present as a progress bar, simply don't
    % mark it. If the increment is not 1, i.e. a loop of the form
    %
    % for var=1:0.5:10
    %
    % then this will be broken. Prefer to write such a loop as:
    %
    % for var_i = 1:19
    %   var = var_i * 0.5 + 1;
    %
    % which can be used to allow indexing into a matrix with the loop variable
    % - generally a useful thing.
    %
    % Nextly, there is functionality for executing some code on request
    % during execution of the loops. For example, if we repeat and experiment
    % 40 times, we may want to look at the results after 5 repetitions, to
    % check that they are sane, rather than wait for the entire experiment to
    % finish.
    %
    % To this end, it is possible to annotate the final part of a script with
    %
    % %%Finalise
    % <Code>
    %
    % (or finalize, if you prefer). This indicates that everything after the
    % tag can be executed during the script at any point, with some useful
    % purpose; see PROGRESS_EXAMPLE for an example. Remember that the code
    % after %%finalise can be executed at any time, so may need to be
    % cleverly designed in order to display something useful.
    %
    % Alternatively, if the progress bars are not being used along with
    % automatic boilerplate code generation, it is possible to create a
    % progress bar which will execute a custom function when the 'Finalise'
    % button is pressed. Simply create the bar with:
    %
    % pr = Progress(my_function);
    %
    % Running Progress.annotate('script_name') (where the script name should not
    % include .m) will produce a file: script_name_pr.m with the added
    % annotations, and (if the %%finalise tag was used) script_name_fn.m.
    % script_name_pr can be run as normal and progress bars will work as
    % expected.
    % The ideal way to run scripts with a progress bar is to prepend
    %
    % prog;return;
    %
    % to the script (it should be the first thing that happens when the script
    % is invoked). This will annotate the script, run the annotated script in
    % the base workspace, and delete the annotated script.
    %
    % Alternatively, run the script with:
    %
    % prog('script_name');
    %
    % for the same effect.
    %
    % Error messages will be slightly broken when running with progress bars
    % in this way; the line numbers in an error message will refer to the
    % lines of the annotated script (which can be produced with
    % Progress.annotate('script_name');).
    %
    % Too long; didn't read?
    % Take a script that you want progress bars for. Add "prog;return;" as the
    % first line in the script. Put "%%p1" at the end of the first for loop
    % and its corresponding end. Put "%%p2" in the same places for the next
    % nested for loop. Continue until all for loops are marked. Then run the
    % script as normal.
    %
    % See Also: PROG, PROGRESS_EXAMPLE, PROGRESS_EXAMPLE2
    
    %Author: Richard Stapenhurst
    %$Date: 6/07/2010$
    
    properties (Constant=true)
        
        %A tab in your code. It is assumed that for-loops should be properly
        %indented. By default this is two spaces.  If indentation looks
        %rubbish, then insert the correct tab size below. Not that it really
        %matters since the _pr.m file shouldn't be looked at anyway.
        tb = '  ';
        %The newline character in your code files. This could conceivably end
        %up being char(13), in which case it needs to to be changed.
        newline = char(10);
        %The highest degree polynomial to fit to a progress bar elapsed time
        %function. O(N^max_degree) is the complexity of the most complex
        %elapsed time function you expect to encounter. Having max_degree too
        %high will probably mess up remaining time predictions for less complex
        %processes.
        max_degree = 1;
        %Whether to allow multiple progress bar windows. They are not typically
        %useful, but might be desirable in some cases. However, enabling them
        %causes lots of annoying variables to turn up in the workspace
        %(prog_terminate1, prog_terminate2 ... prog_terminateN,
        %prog_window_count) which requires Progress.tidy(); to remove them.
        %Setting multiple_windows to false will prevent this, using only the
        %prog_terminate1 variable. If you then try to create multiple progress
        %windows, some behaviour (i.e. process termination) may be unexpected.
        multiple_windows = false;
        %Timestep for automatic updating. Set to <= 0 to disable automatic
        %updating.
        timestep = 1;
        %The colour of the bars; java.awt.Color(Red, Green, Blue, Alpha) where
        %each value is in [0, 1]
        bar_colour = Progress.pale_blue;
        pale_yellow = java.awt.Color(1, 1, 0.2, 0.5);
        pale_blue = java.awt.Color(0.4, 0.4, 1, 0.5);
        pale_green = java.awt.Color(0.4, 1, 0.4, 0.5);
        pale_red = java.awt.Color(1, 0.4, 0.4, 0.5);
        
    end
    
    properties
        
        %JFrame to hold progress bars
        frame;
        %JProgressBar array
        bars;
        %Number of existing progress bars
        bar_count;
        %Variable labels for progress bars
        labels;
        %Minimum values for progress bars
        mins;
        %Maximum values for progress bars
        maxs;
        %Execution start times for progress bars
        start_times;
        %Running times at each iteration of the progress bars
        times;
        %Values at each running time
        values;
        %Coefficients for the values in the bar
        coefs;
        %Index of this window (in case there are multiple progress bar windows)
        window_number;
        %Polynomial approximations to the time-value functions
        polys;
        %Remaining times
        remains;
        %Step sizes (assumed to be 1 at the moment)
        steps;
        %A timer
        ticker;
        finalise_button;
        
    end
    
    methods
        
        function a = Progress(finalise_func)
            try
                %PROGRESS Construct a new progress bar stack
                if (Progress.multiple_windows)
                    try
                        a.window_number = evalin('base', 'prog_window_count') + 1;
                    catch %#ok<CTCH>
                        a.window_number = 1;
                    end
                    assignin('base', 'prog_window_count', a.window_number);
                else
                    a.window_number = 1;
                end
                %Create an empty, hidden frame for progress bars
                a.frame = javaObjectEDT('javax.swing.JFrame', 'Progress');
                a.frame.setDefaultCloseOperation(javax.swing.WindowConstants.DISPOSE_ON_CLOSE);
                a.frame.getContentPane().setLayout([]);
                
                %If there is a finalisation function, create the appropriate button
                %and set the callback.
                if (nargin > 0)
                    a.finalise_button = javaObjectEDT('javax.swing.JButton', 'Finalise');
                    button_handle = handle(a.finalise_button, 'callbackproperties');
                    set(button_handle, 'MouseClickedCallback', {@(obj, evt)evalin('base', finalise_func)});
                    a.frame.getContentPane().add(a.finalise_button);
                    a.finalise_button.setBounds(395, 3, 80, 24);
                end
                
                %Set the terminate flag (false), and some other initial stuff.
                assignin('base', ['prog_terminate' num2str(a.window_number)], false);
                a.bar_count = 0;
                a.coefs = [];
                %Set the default colour of the bars (See constants below)
                javax.swing.UIManager.put('ProgressBar.foreground', ...
                    javax.swing.plaf.ColorUIResource(Progress.bar_colour));
            catch e
                a.frame = [];
            end
            
        end
        
        function push_bar(a, label, min, max)
            %PUSH_BAR Adds a new bar to the progress bar stack
            % Add a new progress bar to the top of the stack. Initialize min/max
            % values and set to the min. The label is displayed as
            % "label: current / max" and updates every time the value is updated
            % (via Progress.set) If this is the first progress bar, the frame
            % becomes visible at this point.
            if ~isempty(a.frame)
                %Increment bar count
                a.bar_count = a.bar_count + 1;
                %Do a small step size (so in a loop like "for x=1:0.01:10" there
                %will still be a noticable change when x goes from 1 to 1.01, instead
                %of only changing when x reaches 2).
                if (max-min < 5)
                    a.coefs(a.bar_count) = 200 * (max - min);
                elseif (max-min > 10000)
                    a.coefs(a.bar_count) = 100 / (max - min);
                else
                    a.coefs(a.bar_count) = 1;
                end
                %Create the JProgressBar
                new_bar = javaObjectEDT('javax.swing.JProgressBar', a.coefs(a.bar_count) * min, ...
                    a.coefs(a.bar_count) * max);
                %Add it to the frame in the right place
                a.frame.getContentPane().add(new_bar);
                %numel(a.finalise_button) tests the existance of the finalisation
                %button; 0 means no button, 1 means button. Pick frame size
                %accordingly.
                a.frame.setSize(400 + (84 * numel(a.finalise_button)), 28 + (a.bar_count * 30));
                new_bar.setBounds(1, (30 * a.bar_count) - 27, 390, 24);
                %Initialise some more stuff
                new_bar.setStringPainted(true);
                new_bar.setValue(min);
                new_bar.setString([label ': ' num2str(min) ' / ' num2str(max)]);
                new_bar.setVisible(1);
                %Add the necessary data to the instance variables.
                a.bars{a.bar_count} = new_bar;
                a.labels{a.bar_count} = label;
                a.mins(a.bar_count) = min;
                a.maxs(a.bar_count) = max;
                a.start_times(a.bar_count) = tic;
                a.times{a.bar_count} = 0;
                a.values{a.bar_count} = min;
                a.remains{a.bar_count} = 100;
                a.steps(a.bar_count) = 1;
                %If it's the first bar, make the frame visible too.
                if (a.bar_count == 1)
                    a.frame.setVisible(1);
                    %Create a close listener
                    frame_handle = handle(a.frame, 'callbackproperties');
                    set(frame_handle, 'WindowClosingCallback', {@(obj, evt)...
                        assignin('base', ['prog_terminate' num2str(a.window_number)], true)});
                    if (Progress.timestep > 0)
                        a.ticker = timer('Period', Progress.timestep, 'TimerFcn', @(varargin)a.update(), ...
                            'executionMode', 'FixedSpacing');
                        start(a.ticker);
                    end
                end
            end
            
        end
        
        function pop_bar(a)
            %POP_BAR Remove the most recent progress bar from the stack.
            % Remove the topmost progress bar from the stack. If this is the only
            % remaining progress bar, this also hides the frame.
            
            if ~isempty(a.frame)
                %Remove the bar
                a.frame.getContentPane().remove(a.bars{a.bar_count});
                %Decrement count
                a.bar_count = a.bar_count - 1;
                %Discard some data. TODO: Take this out? Usually the data can just be
                %overriden.
                %a.bars = a.bars(1:a.bar_count);
                %a.labels = a.labels(1:a.bar_count);
                %a.mins = a.mins(1:a.bar_count);
                %a.maxs = a.maxs(1:a.bar_count);
                %a.start_times = a.start_times(1:a.bar_count);
                %a.times = a.times(1:a.bar_count);
                %a.coefs = a.coefs(1:a.bar_count);
                %Reduce the frame size
                a.frame.setSize(400 + (84 * numel(a.finalise_button)), 28 + (a.bar_count * 30));
                %Hide frame if it's empty
                if (a.bar_count == 0)
                    a.frame.setVisible(0);
                    %Clean up the close listener
                    frame_handle = handle(a.frame, 'callbackproperties');
                    set(frame_handle, 'WindowClosingCallback', {});
                    stop(a.ticker);
                    delete(a.ticker);
                end
            end
        end
        
        function reset(a, varargin)
            %RESET Resets a progress bar
            % RESET() resets the most recent progress bar
            % RESET(Label) resets the progress bar Label
            % This sets the bar's value to it's minimum, and removes all timing
            % data.
            %
            % TODO: If we don't reset the timing data, we could remember stuff
            % about the previous run of the bar. But we should be careful since
            % there may be a complexity difference between runs, as a parent bar
            % increases another parameter or somesuch.
            if ~isempty(a.frame)
                if (nargin == 1)
                    bar_index = a.bar_count;
                elseif (nargin == 2)
                    bar_index = a.find_bar(varargin{1});
                else
                    error('Invalid number of arguments');
                end
                a.start_times(a.bar_count) = tic;
                a.times{a.bar_count} = [];
                a.values{a.bar_count} = [];
                a.set_val(bar_index, a.mins(bar_index));
            end
        end
        
        function bar_index = find_bar(a, bar_name)
            %FIND_BAR Finds the index of a bar given a name/index
            % FIND_BAR(Label) finds the bar with Label as its label
            % FIND_BAR(Index) just returns the index
            % This allows label and index to be used interchangably as parameters
            % to various other methods.
            if ~isempty(a.frame)
                if ischar(bar_name)
                    bar_index = find(cell2mat(cellfun(@(x)strcmp(x, bar_name), a.labels, ...
                        'UniformOutput', false)));
                else
                    bar_index = bar_name;
                end
                if (numel(bar_index) == 0 || bar_index > a.bar_count)
                    error(['Invalid bar name:' bar_name]);
                end
            end
        end
        
        function set_message(a, message)
            if ~isempty(a.frame)
                bar_index = a.bar_count;
                a.labels{bar_index} = message;
            end
        end
        
        function set_val(a, varargin)
            %SET Set the value of a progress bar.
            % SET(Value) sets the most recent progress bar to value.
            % SET(Label, Value) sets the bar Label to Value
            % Should be called when the progress bar needs to change. The new
            % value is reflected in the progress-ness of the bar, and the string.
            
            %Let the swing thread assign the terminate flag if necessary
            if ~isempty(a.frame)
                drawnow;
                %Check for terminate flag
                if (evalin('base', ['prog_terminate' num2str(a.window_number)]))
                    %Clean up the close listener
                    frame_handle = handle(a.frame, 'callbackproperties');
                    set(frame_handle, 'WindowClosingCallback', {});
                    %Remove the finalise button callback if it exists.
                    if numel(a.finalise_button)
                        button_handle = handle(a.finalise_button, 'callbackproperties');
                        set(button_handle, 'MouseClickedCallback', {});
                    end
                    a.remove_ticker();
                    error('Terminated by user');
                end
                
                if (nargin == 2)
                    value = varargin{1};
                    bar_index = a.bar_count;
                elseif (nargin == 3)
                    bar_index = a.find_bar(varargin{1});
                    value = varargin{2};
                else
                    error('Invalid number of arguments');
                end
                
                %Set the value and string of the topmost progress bar.
                a.bars{bar_index}.setValue(a.coefs(bar_index) * value);
                
                %Find elapsed time and fit a polynomial curve to it
                elapsed = toc(uint64(a.start_times(bar_index)));
                a.times{bar_index} = [a.times{bar_index} elapsed];
                a.values{bar_index} = [a.values{bar_index} value];
                %Find the number of distinct samples (ignore samples where either the
                %value or the time is duplicated)
                samples = min(numel(unique(a.times{bar_index})), numel(unique(a.values{bar_index})));
                
                %We need to fit a polynomial to the elapsed time. We'll try to use a
                %2nd degree polynomial, but if there isn't enough data, or if this
                %gives as an absurd result (i.e. negative execution time), we'll
                %reduce the degree.
                degree = min(samples - 1, Progress.max_degree);
                remain = -1;
                while (remain < 0 && degree >= 1)
                    %The polyfit function takes two variables; the first is a list of
                    %times when Progress.set should have been called (i.e. at each step).
                    %The second is a list of elapsed times. The polynomial should compute
                    %an elapsed time as a function of the progress.
                    a.polys{bar_index} = polyfit(a.values{bar_index}, ...
                        a.times{bar_index}, degree);
                    %Use polynomial to predict the total execution time
                    prediction = fliplr(a.maxs(a.bar_count) .^ (0:degree)) * a.polys{bar_index}';
                    
                    remain = prediction - elapsed;
                    degree = degree - 1;
                end
                a.remains{bar_index} = max(remain, 0);
                
                %Format the remaining time string
                timeString = Progress.get_time_string(a.remains{bar_index});
                a.bars{bar_index}.setString([a.labels{bar_index} ': ' num2str(value) ' / ' num2str(a.maxs(bar_index)) '  ' timeString]);
            end
        end
        
        function update(a)
            %UPDATE - Update during the interim between calls to pr.set(). This maintains
            %the illusion of progress to pacify impatient matlabbers.
            
            if ~isempty(a.frame)
                %I don't remember why this try-catch is here. Scary stuff!
                try
                    for b=1:a.bar_count
                        
                        %Only update bars with at least two observations
                        if (numel(a.values{b}) >= 1)
                            
                            %Find a new elapsed time
                            elapsed = toc(uint64(a.start_times(b)));
                            %Line search for interim progress, starting from current progress
                            prediction = -1;
                            next_value = a.values{b}(end);
                            %Loop until a polynomial predicts that it will take longer than
                            %the currently elapsed time. Saturated when we get to the next
                            %expected observation, just in case.
                            old_value = next_value;
                            while ~isempty(a.polys) && (elapsed > prediction && next_value < a.values{b}(end) + a.steps(b))
                                old_value = next_value;
                                %Step size of 1%
                                next_value = next_value + (a.maxs(b) - a.mins(b)) / 100;
                                %Predict the elapsed time for this observation
                                prediction = fliplr(next_value .^ (0:(numel(a.polys{b})-1))) * a.polys{b}';
                            end
                            a.bars{b}.setValue(a.coefs(b) * old_value);
                            %Just decrement the remaining time, saturate at 0.
                            a.remains{b} = max(a.remains{b} - Progress.timestep, 0);
                            
                            %Format the remaining time string
                            timeString = Progress.get_time_string(a.remains{b});
                            a.bars{b}.setString([a.labels{b} ': ' num2str(a.values{b}(end)) ' / ' num2str(a.maxs(b)) '  ' timeString]);
                            
                        end
                        
                    end
                catch %#ok<CTCH>
                end
                
                drawnow;
                %Check for terminate flag, just delete the timer for this event (need
                %to wait for the main thread to execute pr.set(value) before it will
                %actually terminate).
                if (evalin('base', ['prog_terminate' num2str(a.window_number)]))
                    a.remove_ticker();
                end
            end
            
        end
        
        function remove_ticker(a)
            %REMOVE_TICKER Stop and remove the timer object. Many terrible things
            %happen if this isn't done.
            if ~isempty(a.frame)
                if (numel(a.ticker))
                    stop(a.ticker);
                    delete(a.ticker);
                    a.ticker = [];
                end
            end
            
        end
        
    end
    
    methods (Static=true)
        
        function annotate(script_name)
            %ANNOTATE add some boilerplate code to display progress bars
            % Take a file with for-loops and add the boilerplate code for a
            % progress bar, then emit to a temporary file. The code for this is
            % super-messy.
            
            %File stuff. Open the original script, and create the output file
            %(script_name_pr.m).
            input = fopen(script_name);
            %Read the script into an array
            text = fread(input, '*char')';
            
            
            finalise_start = [strfind(text, '%%Finalise') strfind(text, '%%finalise') ...
                strfind(text, '%%Finalize') strfind(text, '%%finalize')];
            fin_file_name = '';
            if (finalise_start) %#ok<BDSCI,BDLGI>
                finalise_string = text(finalise_start(1):end);
                %I could leave this in to strip the finalise code. But probably we
                %want it in anyway; we want to run the code when we reach the end!
                %text = text(1:finalise_start(1)-1);
                finalise_file = [script_name(1:end-2) '_fn.m'];
                output = fopen(finalise_file, 'w');
                fprintf(output, '%s', finalise_string);
                fin_file_name = ['''' script_name(1:end-2) '_fn'''];
            end
            
            %Get a newline character.
            cr = Progress.newline;
            %Strip the first line of the script: "prog;return;" so that the new
            %version will run the actual code. prog; and return; should be
            %separated by either nothing, a space, or a newline.
            return_index_end = [strfind(text, 'prog;return;')+12 ...
                strfind(text, 'prog; return;')+13 strfind(text, ['prog;' cr 'return;'])+13];
            %Remove it if it was found; otherwise we are annotating a script
            %without prog;return;
            if (return_index_end) %#ok<BDSCI,BDLGI>
                text = text(return_index_end:end); %#ok<BDSCI>
            end
            %Ensure file ends with cr cr, just in case the final line is an
            %end %%p1.
            if (text(end) ~= cr)
                text = [text cr cr];
            else
                text = [text cr];
            end
            %Buffers are used to construct the annotated file, starting at the
            %top and bottom, and meeting in the middle.
            start_buffer = ['pr = Progress(' fin_file_name ');' cr];
            end_buffer = [cr 'Progress.tidy();'];
            
            %Find the first tag
            annotation = strfind(text, '%%p1');
            %Set the index of the tag we are looking at
            index = 1;
            %new_tab and old_tab are used to remember the indentation, which
            %should keep the boilerplate code properly indented.
            old_tab = '';
            while (annotation)
                
                %Add another level of indentation
                new_tab = [old_tab Progress.tb];
                %Strip text prior to the marked for-loop and add it to the
                %buffer.
                preamble = find(text(1:annotation(1)) == cr, 1, 'last');
                start_buffer = [start_buffer text(1:preamble)]; %#ok<AGROW>
                %Pull out the for-loop line.
                line = text(preamble+1:annotation(1) - 1);
                
                %Parse the for loop syntax to extract start/end values
                %for variable_name = var_min : var_max
                %If the loop has a step that is not 1, then it is not supported.
                %TODO: Extract steps, then rewrite the loop with a step of 1 and
                %assign the original variable by dividing the new variable by
                %something.
                var_start = strfind(line, 'for') + 3;
                while (line(var_start) == ' ')
                    var_start = var_start + 1;
                end
                equals = find(line(var_start:end) == '=', 1) + var_start - 1;
                min_start = equals + 1;
                while (line(min_start) == ' ')
                    min_start = min_start + 1;
                end
                colon = find(line(min_start:end) == ':', 1) + min_start - 1;
                max_start = colon + 1;
                while (line(max_start) == ' ')
                    max_start = max_start + 1;
                end
                var_name = line(var_start:equals - 1);
                min_str = line(min_start:colon - 1);
                max_str = line(max_start:end);
                max_str = max_str(max_str ~= ';');
                
                var_name = var_name(var_name ~= ' ');
                %This is a bit messy, because we are assuming that the min is 1,
                %sort of. The progress bar displays values between min_str and
                %max_str. The problem is that we want it to display max_str when we
                %are 100% done, so the current string on the bar is the amount
                %completed. At the start of the loop, we haven't completed an
                %iteration for the min value. Here we subtract 1 (so a loop of 1:10
                %will show 0-1-2-3-4-5-6-7-8-9-10), but it will be weird when a
                %loop of 3:5 shows 2-3-4-5. There isn't much that can be done if we
                %want to retain sensible behaviour. Perhaps convert to a
                %percentage, but then we lose information.
                min_str = num2str(str2double(min_str(min_str ~= ' ')) - 1);
                max_str = max_str(max_str ~= ' ');
                
                %Add the push_bar command prior to the for loop, then the for loop
                start_buffer = [start_buffer old_tab ...
                    'pr.push_bar(''' var_name ''', ' min_str ', ' max_str ');' cr ...
                    line]; %#ok<AGROW>
                
                %Find the stuff following the corresponding marked end
                postamble = find(text(annotation(2):end) == cr, 1) + annotation(2) - 1;
                
                %Pull out the end line
                end_line = text((find(text(annotation(1):annotation(2)) == cr, 1, 'last') ...
                    + annotation(1)):annotation(2) - 1);
                %Add a progress bar set before the end. Then add the end line. Then
                %add a pop_bar. Then add all the other stuff.
                end_buffer = [new_tab 'pr.set_val(' var_name ');' cr ...
                    end_line cr ...
                    old_tab 'pr.pop_bar();' cr ...
                    text(postamble+1:end) end_buffer]; %#ok<AGROW>
                
                %Remove the text that has been added to the buffers, leaving us
                %with the contents of the for-loop
                text = text(preamble+numel(line)+1:annotation(2) - numel(end_line) - 1);
                %Search for the next tag
                index = index + 1;
                annotation = strfind(text, ['%%p' num2str(index)]);
                old_tab = new_tab;
                
            end
            
            new_file = [script_name(1:end-2) '_pr.m'];
            output = fopen(new_file, 'w');
            %The final file will be all the stuff from the start, the striped
            %text (i.e. the content of the innermost marked for-loop), and then
            %all the stuff from the end.
            fprintf(output, '%s', [start_buffer text end_buffer]);
            
            fclose('all');
            
        end
        
        function tidy()
            %TIDY Removes some of the global variables used by progress bars
            % If Progress.multiple_windows is true, then each time a progress bar
            % is created, it will add another variable to the global workspace to
            % track termination conditions. To remove these variables, used
            % Progress.tidy(); or set Progress.multiple_windows to false.
            
            if (evalin('base', 'exist(''prog_window_count'', ''var'')'))
                window_count = evalin('base', 'prog_window_count');
                for i=1:window_count
                    evalin('base', ['clear(''prog_terminate' num2str(i) ''')']);
                end
                evalin('base', 'clear(''prog_window_count'')');
            end
            
        end
        
        function timeString = get_time_string(remain)
            %GET_TIME_STRING Turn the number of seconds (remain) into a nicely
            %formatted time string:
            %| Remain: <Hours:>Minutes:Seconds
            
            hours = floor(remain / 3600);
            remain = remain - hours*3600;
            minutes = floor(remain / 60);
            seconds = mod(floor(remain), 60);
            %Make sure the seconds string has two digits.
            if hours > 1
                timeString = sprintf('%02d:%02d:%02d', hours, minutes, seconds);
            else
                timeString = sprintf('%02d:%02d', minutes, seconds);
            end
            
        end
        
    end
    
end