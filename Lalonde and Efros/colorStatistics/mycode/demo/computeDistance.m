function dist = computeDistance(histPath, histFiles, hist, type)
% Computes the distance from a histogram to all histograms split across
% several files

dist = [];
p = progressbar;
p = setMessage(p, sprintf('Computing %s distance to all instances in the database...', type));
for i_file = 1:length(histFiles)
    p = setStatus(p, i_file/length(histFiles));
    display(p);
    
    h = load(fullfile(histPath, histFiles{i_file}));
    validInd = find(cellfun(@(x) ~isempty(x), h.concatHisto));
    
    if isempty(dist)
        dist = Inf.*ones(1, length(h.concatHisto));
    end

    curDist = zeros(1, length(validInd));
    for i_histo = 1:length(validInd)
        curDist(i_histo) = chisq(hist, h.concatHisto{validInd(i_histo)});
    end

    dist(validInd) = curDist;
    clear('h');
end