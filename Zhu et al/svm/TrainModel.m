function [model] = TrainModel(data, label, opts)

% if nargin == 3
%     weights = ones(size(label));
% end

libsvm_options = sprintf('-s %d -t %d -c %f -p %f', opts.svmType, ...
    opts.kernelType, opts.cost, opts.epsilon);
if ~opts.verbose
    libsvm_options = [libsvm_options ' -q'];
end

model = svmtrain(label, data, libsvm_options);
end