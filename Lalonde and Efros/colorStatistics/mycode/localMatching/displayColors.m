function displayColors(pixelVector, colors)

nbDims = size(pixelVector, 2);
indDisplay = randperm(size(pixelVector, 1));
indDisplay = indDisplay(1:min(1500, size(pixelVector, 1)));

pixelVector = double(pixelVector);

if nbDims == 1

elseif nbDims == 2
    % display 2-D plot with points color-coded
    scatter(pixelVector(indDisplay,1), pixelVector(indDisplay,2), 15, double(colors(indDisplay,:))./255, 'filled');
    xlabel('1'), ylabel('2'), zlabel('3');

elseif nbDims == 3
    % display 3-D plot with points color-coded
    scatter3(pixelVector(indDisplay,1), pixelVector(indDisplay,2), pixelVector(indDisplay,3), 15, double(colors(indDisplay,:))./255, 'filled');
    xlabel('1'), ylabel('2'), zlabel('3');
end