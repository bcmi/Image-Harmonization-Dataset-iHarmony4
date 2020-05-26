function [fim] = applyFilter(f,im)
% function [fim] = applyFilter(f,im)
%
% Apply a filter to an image with reflected boundary conditions.
%
% See also fbCreate, fbRun.
%
% David R. Martin <dmartin@eecs.berkeley.edu>
% March 2003

fim = fbRun({f},im);
fim = fim{1};
