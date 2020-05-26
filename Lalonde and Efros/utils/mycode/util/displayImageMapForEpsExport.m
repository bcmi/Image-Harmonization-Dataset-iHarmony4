function displayImageMapForEpsExport(img, xAxis, yAxis, figHandle, cmap, cBarLim, cBarTick, xTick, yTick)

figure(figHandle);
image(xAxis, yAxis, img, 'CDataMapping', 'scaled');
axis image off;
caxis(cBarLim); colormap(cmap);

set(gca(figHandle), 'XTick', xTick, 'YTick', yTick);
    
f = getframe(gca(figHandle));

% Create new x and y axes based on the previous ones
newXAxis = linspace(xAxis(1)-(xAxis(2)-xAxis(1))/2, xAxis(end)+(xAxis(2)-xAxis(1))/2, length(xAxis));
newYAxis = linspace(yAxis(1)-(yAxis(2)-yAxis(1))/2, yAxis(end)+(yAxis(2)-yAxis(1))/2, length(yAxis));
image(newXAxis, newYAxis, f.cdata); 

axis image on;
set(gca(figHandle), 'XTick', xTick, 'YTick', yTick);

colorbar;
caxisLims = get(colorbar, 'YLim');
colorbar('YTickLabel', cBarTick, 'YTick', linspace(caxisLims(1), caxisLims(2), length(cBarTick)));
