function [rocScore, result] = CrossValidationTest(data, labels, opts, num_fold)
nData = numel(labels);
posIds = find(labels==1);
negIds = find(labels==0);
rand_pos = randperm(numel(posIds));
rand_neg = randperm(numel(negIds));

num_pos_test = ceil(numel(posIds)/num_fold);
num_neg_test = ceil(numel(negIds)/num_fold);

all_id = 1 : nData;
test_ids = cell(num_fold, 1);
train_ids  = cell(num_fold, 1);
pred = zeros(nData, 1);
score = zeros(nData, 1);

for k = 1 : num_fold
    pos_test_ids = posIds(rand_pos(num_pos_test*(k-1)+1:min(end, num_pos_test*k)));
    neg_test_ids = negIds(rand_neg(num_neg_test*(k-1)+1:min(end, num_neg_test*k)));
    test_id = [pos_test_ids;neg_test_ids];
    train_id = setdiff(all_id, test_id);
    test_ids{k} = test_id;
    train_ids{k} = train_id;
    trainLabels = labels(train_id);
    testLabels = labels(test_id);
    trainData = data(train_id, :);
    testData = data(test_id, :);
    model = TrainModel(trainData, trainLabels, opts);
    pred(test_id) = TestModel(testData, testLabels, model);
    w = (model.sv_coef' * full(model.SVs));
    bias = -model.rho;
    score(test_id) = testData * w' + bias;
end

result.pred = pred;
result.score = score;
result.accu = sum(pred==labels)/numel(labels);
[~, tpr, fpr, ~]  = prec_rec(score, labels, 'plotPR',0, 'plotROC', 1);
rocScore = auroc(tpr, fpr);
fprintf('rocScore = %3.3f\n', rocScore);
result.roc = rocScore;
result.train_ids = train_ids;
result.test_ids = test_ids;
end

