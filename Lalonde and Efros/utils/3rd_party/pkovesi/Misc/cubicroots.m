% CUBICROOTS - finds real valued roots of cubic
%
% Usage: root = cubicroots(a,b,c,d)
%
% Arguments:
%     a, b, c, d - coeffecients of cubic defined as
%                  ax^3 + bx^2 + cx + d = 0
% Returns:
%     root   - an array of 1 or 3 real valued roots
% 

% Reference:  mathworld.wolfram.com/CubicFormula.html
% Code follows Cardano's formula

% Copyright (c) 2008 Peter Kovesi
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

% Nov 2008

function root = cubicroots(a,b,c,d)
    
    if abs(a) < eps
        error('this is a quadratic')
    end
    
    % Divide through by a to simplify things
    b = b/a; c = c/a; d = d/a;
    bOn3 = b/3;
    
    q = (3*c - b^2)/9;
    r = (9*b*c - 27*d - 2*b^3)/54;
    discriminant = q^3 + r^2;
    
    if discriminant >= 0        % We have 1 real root and 2 imaginary
        s = realcuberoot(r + sqrt(discriminant));   
        t = realcuberoot(r - sqrt(discriminant));
    
        root = s + t - bOn3;    % Just calculate the real root
        
    else                        % We have 3 real roots

        % In this case (r + sqrt(discriminate)) is complex so the following
        % code constructs the cube root of this complex quantity
        
        rho = sqrt(r^2 - discriminant); 
        cubeRootrho = realcuberoot(rho); % Cube root of complex magnitude
        thetaOn3 = acos(r/rho)/3;        % Complex angle/3
        
        crRhoCosThetaOn3 = cubeRootrho*cos(thetaOn3);
        crRhoSinThetaOn3 = cubeRootrho*sin(thetaOn3);   

        root = zeros(1,3);
        root(1) = 2*crRhoCosThetaOn3 - bOn3;
        root(2) =  -crRhoCosThetaOn3 - bOn3 - sqrt(3)*crRhoSinThetaOn3;
        root(3) =  -crRhoCosThetaOn3 - bOn3 + sqrt(3)*crRhoSinThetaOn3;
    end    

    
%-----------------------------------------------------------------------------
% REALCUBEROOT - computes real-valued cube root
%
% Usage:   y = realcuberoot(x)
%
% In general there will be 3 solutions for the cube root of a number. Two
% will be complex and one will be real valued.  When you raise a negative
% number to the power 1/3 in MATLAB you will not, by default, get the real
% valued solution. This function ensures you get the real one

function y = realcuberoot(x)
    
    y = sign(x).*abs(x).^(1/3);