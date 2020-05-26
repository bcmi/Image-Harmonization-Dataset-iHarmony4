% saveEpsFigure(figHandle, outputFilename)
function saveEpsFigure(figHandle, outputFilename)

% fontSize = 14;

% axesHandle = get(figHandle, 'CurrentAxes');
% set(axesHandle, 'FontSize', fontSize);

figure(figHandle);
% set(figHandle, 'PaperPositionMode', 'auto');
set(figHandle, 'InvertHardcopy', 'off');
print('-depsc2', outputFilename);
% saveas(figHandle, outputFilename, 'psc2');



