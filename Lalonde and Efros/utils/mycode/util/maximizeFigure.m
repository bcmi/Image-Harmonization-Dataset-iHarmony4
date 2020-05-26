function maximizeFigure(figHandle)

scrsz = get(0, 'ScreenSize'); 
set(figHandle, 'Position', [1 scrsz(4) scrsz(3) scrsz(4)]);
