% NEEDLEPLOTST - needleplot of 3D surface from slant tilt data
%
% Usage:  needleplotst(slant, tilt, len, spacing)
%
%        slant, tilt - 2D arrays of slant and tilt values
%        len         - length of needle to be plotted
%        spacing     - sub-sampling interval to be used in the
%                      slant and tilt data. (Plotting every point
%                      is typically not feasible)

% Peter Kovesi  
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk @ csse uwa edu au
% http://www.csse.uwa.edu.au/~pk
%
% July 2003

function needleplotst(slant, tilt, len, spacing)

    lw = 1;  % linewidth
  if ~all(size(slant) == size(tilt))
    error('slant matrix must have same dimensions as tilt');
  end

  % Subsample the slant and tilt matrices according to the specified spacing
  s_slant = slant(1:spacing:end, 1:spacing:end);
  s_tilt = tilt(1:spacing:end, 1:spacing:end);

  [s_rows, s_cols] = size(s_slant);

  projlen = len*sin(s_slant);   % projected length of each needle onto xy plane
  dx = projlen.*cos(s_tilt);
  dy = projlen.*sin(s_tilt);

  clf
  for r = 1:s_rows
    for c = 1:s_cols
      x = (c-1)*spacing+1;
      y = (r-1)*spacing+1;
      h = plot(x,y,'bo'); hold on
      set(h,'MarkerSize',2);
      line([x x+dx(r,c)],[y y+dy(r,c)],'color',[0 0 1],'linewidth',lw);
    end
  end
  axis('equal')
  hold('off')
