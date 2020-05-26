function p=progressbar(pr)
% Creates a progress bar object
%   
%   p = progressbar
%
% See also:
%   progressbar/setMessage
%   progressbar/setStatus

if nargin==0
    p.progress_bar_position=0;
    p.relapsed_time=0.01;
    p.initTime = clock;
    p.message = '';
    
    p=class(p,'progressbar');
       
elseif isa(pr,'progressbar')
    p=pr;
end
end