%PROGRESS_EXAMPLE2 Progress bar example.
%
% Creates some data and fits a CART tree to it. The experiment investigates
% the effect of how much data is used to fit a linear regression. It is repeated
% 50 times. Progress bars are manually included.
%
% See also: PROGRESS, PROG

%Author: Richard Stapenhurst
%$Date: 6/07/2010$  

reps = 50;
examples = 10000;
ex_counts = 5:50;
errors = zeros(reps, numel(ex_counts));

inputs = (rand(examples, 1) + mod(1:examples, 2)') + (rand(examples, 1)) - 0.5;
outputs = mod(1:examples, 2)';

%This could be replaced with pr = Progress(@()special_function()); in order
%to call special_function() during process execution by pressing a button.
pr = Progress();

%Add a new bar to the stack. Parameters are Title, min value, max value.
pr.push_bar('Repetition', 1, reps);
for rep=1:reps
  
  indices = randperm(examples);
  inputs = inputs(indices);
  outputs = outputs(indices);
  
  %Add another bar to the stack
  pr.push_bar('Parameter', 1, numel(ex_counts));
  for ex_index=1:numel(ex_counts)
    
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
    
    %Update the 'Parameter' bar
    pr.set_val(ex_index);   
  end
  %Remove the 'Parameter' bar (it will be replaced at the next iteration)
  %This could be replaced by pr.reset(), to avoid the overhead of
  %destroying/creating the bar, in which case the following pr.set_val(rep)
  %would have to become pr.set_val('Repetition', rep). This breaks the
  %conceptually convenient way of thinking of progress bars as a stack.
  pr.pop_bar();
  
  %Set the new value for the reptition bar.
  pr.set_val(rep);
end
%Remove the repetition bar.
pr.pop_bar();

figure(1);
plot(ex_counts, mean(errors, 1));
xlabel('Amount of training data');
ylabel('Generalisation Error');