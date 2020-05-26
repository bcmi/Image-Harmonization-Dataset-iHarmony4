function A = auroc(tp, fp)
%
% AUROC - area under ROC curve
%
%    An ROC (receiver operator characteristic) curve is a plot of the true
%    positive rate as a function of the false positive rate of a classifier
%    system.  The area under the ROC curve is a reasonable performance
%    statistic for classifier systems assuming no knowledge of the true ratio
%    of misclassification costs.
%
%    A = AUROC(TP, FP) computes the area under the ROC curve, where TP and FP
%    are column vectors defining the ROC or ROCCH curve of a classifier
%    system.
%
%    [1] Fawcett, T., "ROC graphs : Notes and practical
%        considerations for researchers", Technical report, HP
%        Laboratories, MS 1143, 1501 Page Mill Road, Palo Alto
%        CA 94304, USA, April 2004.
%
%    See also : ROC, ROCCH

%
% File        : auroc.m
%
% Date        : Wednesdaay 11th November 2004 
%
% Author      : Dr Gavin C. Cawley
%
% Description : Calculate the area under the ROC curve for a two-class
%               probabilistic classifier.
%
% References  : [1] Fawcett, T., "ROC graphs : Notes and practical
%                   considerations for researchers", Technical report, HP
%                   Laboratories, MS 1143, 1501 Page Mill Road, Palo Alto
%                   CA 94304, USA, April 2004.
%
% History     : 22/03/2001 - v1.00
%               10/11/2004 - v1.01 minor improvements to comments etc.
%
% Copyright   : (c) G. C. Cawley, November 2004.
%
%    This program is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program; if not, write to the Free Software
%    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
%

n = size(tp, 1);
A = sum((fp(2:n) - fp(1:n-1)).*(tp(2:n)+tp(1:n-1)))/2;

% bye bye...

