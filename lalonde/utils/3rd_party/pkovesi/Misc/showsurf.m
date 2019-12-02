% SHOWSURF - shows parametric surface in a convenient way
%
% This function wraps up the commands I usually use to display a surface.
%
% The surface is displayed using SURFL with interpolated shading, in my
% favourite colormap of 'copper', with rotate3d on, and axis vis3d set.
%
% Usage can be any of the following
%         showsurf(Z)
%         showsurf(Z, figNo)
%         showsurf(Z, title)
%         showsurf(Z, figNo, title)
%         showsurf(X, Y, Z)
%         showsurf(X, Y, Z, figNo)
%         showsurf(X, Y, Z, title)
%         showsurf(X, Y, Z, figNo, title)
%
% If no figure number is specified a new figure is created. If you want the
% current figure or subplot to be used specify 0 as the figure number.
%
% See also: SHOW

% Copyright (c) 2009 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.
 
% PK May 2009

function showsurf(varargin)
    
    [X,Y,Z,figNo,titleString] = checkargs(varargin(:));

    if figNo == -1
        figure
    elseif figNo > 0
        figure(figNo), clf
    end
    
    surfl(X,Y,Z), shading interp, colormap(copper)
    rotate3d on, axis vis3d, title(titleString);
    
    
%------------------------------------------------    
function  [X,Y,Z,figNo,title] = checkargs(args)
    
    nArgs = length(args);
    sze = cell(nArgs,1);
    for n = 1:nArgs
        sze{n} = size(args{n});
    end
    
    % default values
    figNo = -1;        % Value to indicate create new window
    title = '';
    
    if nArgs == 1      % Assume we user has only supplied Z
       [X,Y] = meshgrid(1:sze{1}(2),1:sze{1}(1));
       Z = args{1};

    elseif nArgs == 2  % We have Z,figNo or Z,title
        if strcmp(class(args{2}),'char')
            title = args{2};
        else
            figNo = args{2};
        end
        [X,Y] = meshgrid(1:sze{1}(2),1:sze{1}(1));
        Z = args{1};        
        
    elseif nArgs == 3  % We have Z,figNo,title or X,Y,Z        
        if strcmp(class(args{3}),'char')
            [X,Y] = meshgrid(1:sze{1}(2),1:sze{1}(1));
            Z = args{1};    
            figNo = args{2};            
            title = args{3};        
        else
            X = args{1};
            Y = args{2};            
            Z = args{3};                        
        end
        
    elseif nArgs == 4  % We have  X,Y,Z,figNo or X,Y,Z,title
        if strcmp(class(args{4}),'char')
            title = args{4};
        else
            figNo = args{4};
        end
    
        X = args{1};
        Y = args{2};            
        Z = args{3};                                
        
    elseif nArgs == 5  % We have  X,Y,Z,figNo,title    
        X = args{1};
        Y = args{2};            
        Z = args{3};                                
        figNo = args{4};                
        title = args{5};
    else
        error('Wrong number of arguments');
    end

    % Final sanity check because the code above made quite a few assumptions
    % about the validity of the supplied arguments
    if ~all(size(X)==size(Y)) || ~all(size(X)==size(Z))
        error('X,Y,Z must have the same dimensions');
    end
    
    if ~strcmp(class(title),'char')
        error('Expecting a string for the figure title');
    end
    
    if length(figNo) ~= 1 || ~isnumeric(figNo)
        error('Figure number should be a single numeric value');
    end
    