function [pred] = TestModel(data, label, model)
% weights = zeros([size(data, 1), 1]); 
% w = (model.sv_coef' * full(model.SVs));
% b = -model.rho;
% pred = sign(data * w' + b);
pred = svmpredict(label,data, model, '-q'); 
end

