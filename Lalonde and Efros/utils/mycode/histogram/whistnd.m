function h = whistnd(data, weights, varargin)
%HISTND N-D histogram count
%   H = HISTND(DATA, EDGE1, EDGE2, EDGE3, ...) returns a histogram
%   matrix which is EDGE1-by-EDGE2-by-EDGE3-by-... in size, where
%   each element is the number of realizations of DATA that fall
%   within the appropriate bin in each respective EDGE vector.
%   DATA must be an M-by-N matrix, where M is the number of
%   realizations and N is the number of types of measurements,
%   whose bins are givin by each EDGE vector.  N must be equal to
%   the number of input EDGE vectors.
%
%   Like the MATALAB function HISTC, H(k1, k2, k3, ...) will count
%   the realization DATA(i, :) if:
%       EDGE1(k1) <= DATA(i, 1) < EDGE1(k1+1) AND
%       EDGE2(k2) <= DATA(i, 2) < EDGE2(k2+1) AND
%       EDGE3(k3) <= DATA(i, 3) < EDGE3(k3+1) AND ...
%   Any values outside of their respective EDGE vectors are not
%   counted.  Use -Inf and Inf to include all non-NaN values.
%
%   Example:
%       H = HISTND(RAND(1000, 1), 0:.25:1) is the same as
%       H = HISTC(RAND(1000, 1), 0:.25:1).
%
%       H = HISTND(RESHAPE(PASCAL(6), 18, 2), 0:10:30, 0:100:300)
%       returns the array [14 1 0 0;
%                          1  1 0 0;
%                          0  0 1 0;
%                          0  0 0 0]

%   Created 2/15/2004 by:
%   Ajay Nemani
%   Center for Magnetic Resonance Research
%   University of Illinois at Chicago
%   aneman1@uic.edu
%
%   This program is free software; you can redistribute it and/or
%   modify it under the terms of the GNU General Public License
%   as published by the Free Software Foundation; either version 2
%   of the License, or (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details:
%
%         http://www.gnu.org/copyleft/gpl.html
%


%Check DATA input
if ndims(data) ~= 2
    error('DATA must be a columnwise 2-D matrix');
end

%m = columns = # of data realizations
%n = rows = # of types of measurements
[m, n] = size(data);

%Check that number of measurements in DATA equals number of EDGE vectors
if length(varargin) ~= n
    error('Number of EDGE vectors must equal number of rows of DATA');
end

%Get size vector of output from EDGE vectors
hdim = cellfun('length', varargin);

%Correction of hdim for 1D histogram
if length(hdim) == 1
    hdim = [hdim 1];
end

%Create logical index of realizations that fall within EDGE vectors
inrange(1:m) = true;

%Use HISTC to get bin indices of DATA into respective EDGE vectors
bin = cell(1, n);

for i = 1:n
    [dummy, bin{i}] = whistc(data(:, i), weights, varargin{i});
    inrange(bin{i} == 0) = false;  %Remove out of range realizations
end
clear dummy;

%Use inrange to extract valid realizations
for i = 1:n
    bin{i} = bin{i}(inrange);
end
w = weights(inrange);

%Convert bin indicies to linear indicies into output H,
%then use HISTC once more to count indicies into H
h = reshape( ...
             whistc( ...
                    sub2ind(hdim, bin{:}), ...
                    w, ...
                    1:prod(hdim) ...
                  ), ...
             hdim ...
           );
