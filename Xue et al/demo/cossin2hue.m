function hue = cossin2hue(c, s)   % output :  0~ 1
% c = cos(hue*2*pi)  
% s = sin(hue*2*pi)

t = atan( s ./(c+0.0001) );   %theta = -pi/2 to pi/2
if c < 0
    t = t + pi;     
end

if t<0
    t = t + 2*pi;   % all theta = 0- 2pi
end

hue = t ./ (2*pi);