%PROGRESS_EXAMPLE Progress bar example.
%
% Creates some data and fits a CART tree to it. The experiment investigates
% the effect of how much data is used to fit a linear regression. It is repeated
% 50 times. The code has been annotated so that when the script is run, it
% will automatically display progress on a progress bar.
%
% See also: PROGRESS, PROG

%Author: Richard Stapenhurst
%$Date: 6/07/2010$  

%It's okay to have comments prior to the first line, but don't put
%functional code here.

prog;return;%Put this line at the start of a script

%Unfortunately MATLAB will flag the first line of your real code as a
%warning.
reps = 50;
examples = 10000;
ex_counts = 5:50;
errors = zeros(reps, numel(ex_counts));

inputs = (rand(examples, 1) + mod(1:examples, 2)') + (rand(examples, 1)) - 0.5;
outputs = mod(1:examples, 2)';

%Outer loop: annotate the start and end of the loop with p1
for rep=1:reps %%p1
  
  indices = randperm(examples);
  inputs = inputs(indices);
  outputs = outputs(indices);
  
  %Inner loop: annotate the start and end of the loop with p2
  for ex_index=1:numel(ex_counts) %%p2
    
    %Do linear regression on some examples, and evaluate performance on the
    %rest (this is the experiment).
    temp_inputs = [ones(ex_counts(ex_index), 1) inputs(1:ex_counts(ex_index), :)];
    temp_outputs = [outputs(1:ex_counts(ex_index)) == 0 outputs(1:ex_counts(ex_index)) == 1];
    b_hat = (temp_inputs' * temp_inputs) \ (temp_inputs' * temp_outputs);
    probabilities = ([ones(examples-ex_counts(ex_index), 1) ...
      inputs(ex_counts(ex_index)+1:end)] * b_hat);
    [v i] = max(probabilities, [], 2);
    predictions = i - 1;
    err = mean(predictions ~= outputs(ex_counts(ex_index)+1:end));
    errors(rep, ex_index) = err;
   
  %End of the inner loop
  end %%p2
  
%End of the outer loop
end %%p1
rep = rep + 1;%Increment rep so that the plot statement below will plot data from all repetitions.

%Code that can be executed by pressing 'finalise' on the progress bar.
%%Finalise
figure(1);
%The plot command needs to be written with extra cunning so that it
%displays something meaningful if executed half-way through the experiment.
%In this case, we only plot the results for repetitions that have been
%entirely completed.
plot(ex_counts, mean(errors(1:rep-1, :), 1));
xlabel('Amount of training data');
ylabel('Generalisation Error');