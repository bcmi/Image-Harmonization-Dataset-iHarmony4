function H=plot(x,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% KDE plotting function
%
%  plot(kde)            -- plot a KDE with various features.
%  plot(kde,style)      --  style is of the form
%  plot(kde,dim,style)  --    [STR1,STR2,...] where
%
%  style is of the form [STR1 STR2 STR3...] where
%
%  STR1 is the style to plot the line (1D) or kernel locations (2+D).  Note
%     that options must be specified in lowercase, e.g. 'ro' for red circles.
%     Default style is '-b'
%  STRN is a style for various optional plot features:
%    'W' : show kernel weights (by color: black = low, color in STR1 = high)
%    'S' : show relative kernel sizes, as circles around each center
%    'Bs': show KD-tree structure / bounding boxes, 's' is e.g. '-b' for
%             bounding boxes of solid blue lines
%    'Nd':show d levels of the bounding boxes (d an integer) (default all)
%  The default style is '.b'
%    Example styles:   '*kS-b'  -- black centers, blue variance circles
%                      '.gWS-kB-rN3' -- green dots, colored by weights,
%                          with black variances and 3 levels of bounding
%                          boxes in red.
%                      'S-k' -- just plot variances (no centers), in black
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

dim = []; args = [];
if (nargin == 1)
  dim = 1:getDim(x);
  if (getDim(x) == 1) args = 'b-'; else args = 'b.'; end;
elseif (nargin == 2)
  dim = [1:getDim(x)];
  args = varargin{1};
else 
  dim = varargin{1};
  args = varargin{2};
end;
%
% Separate the arguments into:  [plot info][TAG taginfo][TAG taginfo] ...
%   where TAG is one of 'W','B','S'.
%
F = find(args ~= lower(args)); Fmin = min([F,length(args)+1]);
argsPlot = args(1:Fmin-1);
argsKDE = args(Fmin:length(args));

if (getDim(x) == 1)
  pts = getPoints(x);
  N = 200;   range = [min(pts),max(pts)];
  range(1) = range(1) - .05*(range(2)-range(1));
  range(2) = range(2) + .05*(range(2)-range(1));
  H=draw1D(x,linspace(range(1),range(2),N),argsPlot,argsKDE);
else
  H=drawAllPairs(x,dim,argsPlot,argsKDE);
end;

%
% Internal functions
%
function e=draw1D(x, bins, style, myStyle)
  y = evaluate(x,bins);
  e=plot(bins,y,style);
  
  mx = max(y);
  wts = getWeights(x);
    
  if(strfind(myStyle,'W'))
    holdf = ishold; hold on;
    subStyle = extract(myStyle,'W');
    subStyle=subStyle(2:end); if (length(subStyle)==0) subStyle = '^'; end;
    etmp = stem(getPoints(x), wts, subStyle);
    e = [e;etmp];
    if (~holdf) hold off; end;
  end
  
  if(strfind(myStyle,'S'))
    holdf = ishold; hold on;
    subStyle = extract(myStyle,'S');
    subStyle=subStyle(2:end); if (length(subStyle)==0) subStyle = '--b'; end;

    bw = getBW(x); pts = getPoints(x); type = getType(x);
    for i=1:length(pts)
      xtmp = kde(pts(i), bw(i), 1, type);
      etmp = plot(bins, evaluate(xtmp, bins) * wts(i), subStyle);
      e = [e;etmp];
    end
    
    % for plotting only gaussian kernels faster:
%    gr = repmat(bins, length(wts), 1);
%    wts = repmat(wts', 1, size(gr, 2));
%    pts = repmat(getPoints(x)', 1, size(gr,2));
%    bw = repmat(getBW(x)', 1, size(gr, 2));
%    etmp = plot( bins, (wts.*(1./(sqrt(2*pi)*bw)).*exp(-(gr-pts).^2./(2*bw.^2)))', subStyle);

    e = [e;etmp];
    if (~holdf) hold off; end;
  end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function e=drawAllPairs(x,dims,style,myStyle)
  pts = getPoints(x);
  holdf = ishold;
  e = [];
  Nout = length(dims);
  PlotI2 = triu(repmat(dims ,[Nout,1]), 1);
  PlotI1 = triu(repmat((dims)',[1,Nout]), 1);
  PlotI1 = PlotI1(find(PlotI1)); PlotI2 = PlotI2(find(PlotI2));
  Ncol = fix(sqrt(length(PlotI2))); Nrow = ceil(length(PlotI2)/Ncol);
  for iT=1:length(PlotI2)                   %  output all dimension pairs:
    subplot(Nrow,Ncol,iT);
    holdfs = ishold;
    if (holdf) hold on; end;
    etmp = drawPair(x,[PlotI1(iT),PlotI2(iT)],style,myStyle);
    if (~holdfs) hold off; end;
    e = [e;etmp];
  end;   
  drawnow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function etmp = drawPair(x,dims,style,myStyle)
  pts = getPoints(x);
  etmp = [];
  
  if (strfind(myStyle,'W'))  %plot weight info with color
    subStyle = extract(myStyle,'W');
    %wts = getWeights(x);  wts = wts - min(wts); 
    %if (max(wts)==0) wts = wts+1; else wts = .75*wts/max(wts) + .25; end;
    wts = getWeights(x);  
    wts = .75*wts/max(wts) + .25;
    holdf = ishold;
    for i=1:size(pts,2)
      etmp2 = plot(pts(dims(1),i),pts(dims(2),i),style);   % plot each location and
      hold on;
      etmp = [etmp;etmp2]; ctmp = get(etmp2,'Color');      %  its color in prop.
      set(etmp2,'Color',[1 1 1] - wts(i)*([1 1 1] - ctmp));%  to its weight
    end;
    if (~holdf) hold off; end;
  else                                                    % otherwise, just plot
    if (length(style)~=0)
      etmp = plot(pts(dims(1),:),pts(dims(2),:),style);   %   all locations
  end; end;
  
  if (strfind(myStyle,'S'))  %plot BW info with circles
    subStyle = extract(myStyle,'S');
    subStyle=subStyle(2:end); if (length(subStyle)==0) subStyle = '-b'; end;
    pts = getPoints(x); sig=getBW(x);
	meanX = pts(dims(1),:);
	meanY = pts(dims(2),:);
	sigX = sig(dims(1),:);
	sigY = sig(dims(2),:);
	
	holdf = ishold;	hold on;
	theta = linspace(0,2*pi,100);
	for (i = 1:length(meanX))
      etmp2 = plot(meanX(i)+sigX(i)*cos(theta), meanY(i)+sigY(i)*sin(theta),subStyle);
      etmp = [etmp;etmp2];
	end	
	if (~holdf) hold off; end;    
  end;
  
  if (strfind(myStyle,'B'))  %plot bounding box info with rectangles
    levels = [];
    if (isempty(strfind(myStyle,'N'))) levels = ceil(log2(getNpts(x)));
    else
      subStyle = extract(myStyle,'N');              % get # of balls if spec'd
      levels = sscanf(subStyle(2:end),'%d');
      levels = min(ceil(log2(getNpts(x))), levels);
    end;
    subStyle = extract(myStyle,'B');              % get plot style if spec'd
    subStyle=subStyle(2:end);
    if(isempty(subStyle))     subStyle = '-b';    end
      
    N = getNpts(x);
    indices = []; tmp = [1];
    for i=1:levels
      indices = [indices tmp];
      % get rid of NO_CHILD right children
      rt = double(x.rightch(tmp)) + 1;
      rt = rt .* (rt < N+1) + 1 * (rt > N);
      tmp = [double(x.leftch(tmp))+1   rt];
    end
    
    rX = x.ranges(dims(1),indices);
    rY = x.ranges(dims(2),indices);
    nodesX = x.centers(dims(1),indices);
    nodesY = x.centers(dims(2),indices);
    leavesX = x.centers(dims(1),N+1:end);
    leavesY = x.centers(dims(2),N+1:end);

    squaresX(1,:) = nodesX + rX;
    squaresX(2,:) = nodesX + rX;
    squaresX(3,:) = nodesX - rX;
    squaresX(4,:) = nodesX - rX;
    squaresX(5,:) = nodesX + rX;
    
    squaresY(1,:) = nodesY + rY;
    squaresY(2,:) = nodesY - rY;
    squaresY(3,:) = nodesY - rY;
    squaresY(4,:) = nodesY + rY;
    squaresY(5,:) = nodesY + rY;
    
    holdf = ishold;	hold on;
    for i = 1:length(indices)
      etmp2 = plot(squaresX, squaresY, subStyle);
      etmp = [etmp;etmp2];
    end
%   axis square	
    if (~holdf) hold off; end;
    
  end;  
  
  titlestr = ['Dim ',int2str(dims(1)),' v. ',int2str(dims(2))];
  title(titlestr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function substr=extract(str,tag)
  substr = [];
  loc = strfind(str,tag);
  if (loc)
    substr = str(loc(1):length(str));
    loc = find(substr(2:end) ~= lower(substr(2:end)));
    if (loc) substr = substr(1:loc(1)); end;
  end;
  
