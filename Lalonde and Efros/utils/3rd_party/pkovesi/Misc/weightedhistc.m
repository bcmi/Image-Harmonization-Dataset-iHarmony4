% WEIGHTEDHISTC   Weighted histogram count
%
% This function provides a basic equivalent to MATLAB's HISTC function for
% weighted data. 
%
% Usage: h = weightedhistc(vals, weights, edges)
%
% Arguments:
%       vals - vector of values.
%    weights - vector of weights associated with each element in vals.  vals
%              and weights must be vectors of the same length.
%      edges - vector of bin boundaries to be used in the weighted histogram.
%
% Returns:
%        h - The weighted histogram
%            h(k) will count the weighted value vals(i) 
%            if edges(k) <= vals(i) <  edges(k+1).  
%            The last bin will count any values of vals that match
%            edges(end). Values outside the values in edges are not counted. 
%
% Use bar(edges,h) to display histogram
%
% See also: HISTC

% Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% peter.kovesi at uwa edu au
% 
% November 2010

function h = weightedhistc(vals, weights, edges)
    
    if ~isvector(vals) || ~isvector(weights) || length(vals)~=length(weights)
        error('vals and weights must be vectors of the same size');
    end
    
    Nedge = length(edges);
    h = zeros(size(edges));
    
    for n = 1:Nedge-1
        ind = find(vals >= edges(n) & vals < edges(n+1));
        if ~isempty(ind)
            h(n) = sum(weights(ind));
        end
    end

    ind = find(vals == edges(end));
    if ~isempty(ind)
        h(Nedge) = sum(weights(ind));
    end