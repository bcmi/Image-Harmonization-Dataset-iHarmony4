%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function resizeAndCenterFigure(figHandle, figSize)
% 
% Input parameters:
%  - figHandle: handle to the figure to center and resize
%  - figSize: size [width height]
%
% Output parameters: None
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function resizeAndCenterFigure(figHandle, figSize)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% center the figure, but put it at the right size
screenSize = get(0, 'ScreenSize');
set(figHandle, 'Position', [(screenSize(3)-figSize(1))/2 (screenSize(4)-figSize(2))/2 figSize(1) figSize(2)]);
