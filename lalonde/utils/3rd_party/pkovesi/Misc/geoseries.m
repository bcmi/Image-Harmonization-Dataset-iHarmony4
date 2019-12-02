% GEOSERIES Generate geometric series
%
% Usage 1: s = geoseries(s1, mult, n)
%
% Arguments:      s1 - The starting value in the series.
%               mult - The scaling factor between succesive values.
%                  n - The desired number of elements in the series.
%
% Usage 2: s = geoseries([s1 sn], n)
%
% Arguments: [s1 sn] - Two-element vector specifying the 1st and nth values
%                      in the the series.
%                  n - The desired number of elements in the series.
%
%
% Example: s = geoseries(0.5, 2, 4)
%      s =  0.5000    1.0000    2.0000    4.0000
%
% Alternatively obtain the same series using
%           s = geoseries([0.5 4], 4)

% Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% peter.kovesi at uwa edu au
%
% March 2012

function s = geoseries(varargin)
 
    [s1, mult, n] = checkargs(varargin(:));
    
    s = s1 * mult.^[0:(n-1)];
    
%---------------------------------------------------------------    
% Sort out arguments.  If 1st and last values in series are specified compute
% the multiplier from the desired number of elements.
% max_val = s1*mult^(n-1)
% mult = exp(log(max_val/s1)/(n-1));

function [s1, mult, n] = checkargs(arg)    
    
    if length(arg) == 2 & length(arg{1}) == 2
        s1 = arg{1}(1);
        sn = arg{1}(2);
        n = arg{2};        
        mult = exp(log(sn/s1)/(n-1));
    elseif length(arg) == 3 & length(arg{1}) == 1
        s1 = arg{1};
        mult = arg{2};
        n = arg{3};
    else
        error('Illegal input. Check usage');
    end

    assert(n == round(n) & n > 0, 'Number of elements must be a +ve integer')
        