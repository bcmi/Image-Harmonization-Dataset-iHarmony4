function d = hueDist(h1, h2)   % hue in 0,1
h1 = hueRewind(h1);
h2 = hueRewind(h2);

a = abs(h1-h2);
d = min( a, 1-a  );
