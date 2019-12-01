% Function to create images for the convolution explanation

function [spread, logGabor, gfilter] = convexplpiccis

rows = 200; cols = 200;
wavelength = 16;
sigmaOnf = 0.65;
angl = 1;
thetaSigma = 0.7;

  [x,y] = meshgrid([-cols/2:(cols/2-1)]/cols,...
                   [-rows/2:(rows/2-1)]/rows);
  radius = sqrt(x.^2 + y.^2);       % Matrix values contain *normalised* radius 
                                    % values ranging from 0 at the centre to 
                                    % 0.5 at the boundary.
  radius(rows/2+1, cols/2+1) = 1;   % Get rid of the 0 radius value in the middle 
                                    % so that taking the log of the radius will 
                                    % not cause trouble.



  fo = 1.0/wavelength;                  % Centre frequency of filter.

  % The following implements the log-gabor transfer function.
  logGabor = exp((-(log(radius/fo)).^2) / (2 * log(sigmaOnf)^2));  
  logGabor(rows/2+1, cols/2+1) = 0;     % Set the value at the 0 frequency point 
                                        % of the filter back to zero 
                                        % (undo the radius fudge).


  show(logGabor,1), imwritesc(logGabor, 'loggabor.jpg');

  lp = lowpassfilter([rows,cols],.4,10);   % Radius .4, 'sharpness' 10
    lp = fftshift(lp);
  logGabor = logGabor.*lp;                 % Apply low-pass filter

  show(lp,8);
  imwritesc(lp, 'lp.jpg');
  show(logGabor,2), imwritesc(logGabor, 'loggaborlp.jpg');



  theta = atan2(-y,x);              % Matrix values contain polar angle.
                                    % (note -ve y is used to give +ve
                                    % anti-clockwise angles)
  sintheta = sin(theta);
  costheta = cos(theta);

  % For each point in the filter matrix calculate the angular distance from the
  % specified filter orientation.  To overcome the angular wrap-around problem
  % sine difference and cosine difference values are first computed and then
  % the atan2 function is used to determine angular distance.

  ds = sintheta * cos(angl) - costheta * sin(angl);    % Difference in sine.
  dc = costheta * cos(angl) + sintheta * sin(angl);    % Difference in cosine.
  dtheta = abs(atan2(ds,dc));                          % Absolute angular distance.
  spread = exp((-dtheta.^2) / (2 * thetaSigma^2));     % Calculate the angular 
                                                       % filter component.

  gfilter = spread.*logGabor;

  show(spread,3), imwritesc(spread, 'spread.jpg');
  show(gfilter,4), imwritesc(gfilter, 'filter.jpg');


EO = ifft2(fftshift(gfilter));
EO = fftshift(EO);

imwritesc(real(EO),'realEO.jpg');
imwritesc(imag(EO),'imagEO.jpg');
figure(9),surfl(real(EO)); shading interp, colormap(copper)
figure(10),surfl(imag(EO));shading interp, colormap(copper)
