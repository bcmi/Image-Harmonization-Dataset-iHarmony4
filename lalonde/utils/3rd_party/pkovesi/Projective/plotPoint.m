% PLOTPOINT - Plots point with specified mark and optional text label.
%
% Function to plot 2D points with an optionally specified
% marker and optional text label.
%
% Usage:
%          plotPoint(p)             where p is a 2D point
%          plotPoint(p, 'mark')     where mark is say 'r+' or 'g*' etc
%          plotPoint(p, 'mark', 'text') 
%

%  Peter Kovesi
%  School of Computer Science & Software Engineering
%  The University of Western Australia
%  pk @ csse uwa edu au
%  http://www.csse.uwa.edu.au/~pk
%
%  April    2000
%  November 2006  Typo in setting 'mk' fixed, text offset relative to point improved.


function plotPoint(p, mark, txt)
hold on

mk = 'r+';     % Default mark is a red +

if nargin >= 2
  mk = mark;
end

plot(p(1), p(2), mk);

if nargin == 3
    % Print text next to point - calculate an appropriate amount to offset
    % the text from the point.

    xlim = get(gca,'Xlim');
    ylim = get(gca,'Ylim');    
    offset = min((xlim(2)-xlim(1)),(ylim(2)-ylim(1)))/50;
    
    text(p(1)+offset,p(2)-offset,txt,'Color',mk(1)); 
end



