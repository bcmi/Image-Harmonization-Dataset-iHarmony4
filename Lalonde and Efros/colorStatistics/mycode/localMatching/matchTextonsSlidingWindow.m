function [windowDist, windowThreshold] = matchTextonsSlidingWindow(imgTgt, textonMapTgt, objTextonHisto, threshold)

windowHalfSize = 20;

[r,c,d] = size(imgTgt);
windowDist = ones(r,c);

for i=1+windowHalfSize:r-windowHalfSize
    
    j = 1+windowHalfSize;
    indWindowi = i-windowHalfSize:i+windowHalfSize;
    indWindowj = j-windowHalfSize:j+windowHalfSize;
    
    window = textonMapTgt(indWindowi, indWindowj);
    windowHisto = histc(window(:), 1:1000);
    windowDist(i, j) = chisq(windowHisto, objTextonHisto);
    
    for j=1+windowHalfSize+1:c-windowHalfSize
        windowInc = textonMapTgt(indWindowi, j+windowHalfSize);
        windowDec = textonMapTgt(indWindowi, j-windowHalfSize-1);
        
        % compute the histogram
        windowIncHisto = histc(windowInc(:), 1:1000);
        windowDecHisto = histc(windowDec(:), 1:1000);
        windowHisto = windowHisto + windowIncHisto - windowDecHisto;
        
        % compute and store the distance
        windowDist(i,j) = chisq(windowHisto, objTextonHisto);
    end
end

ind = find(repmat(windowDist, [1 1 3]) < threshold);
windowThreshold = zeros(size(imgTgt,1), size(imgTgt,2), 3, 'uint8');
windowThreshold(ind) = imgTgt(ind);