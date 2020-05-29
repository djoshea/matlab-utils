% REMOVETREND - Fit a polynomial trend to a surface and remove it.
%
% Usage: [newimg, trend, coef] = removetrend(img, order, spacing)
%
% Arguments:
%        img - Grid of values.
%      order - Order of polynomial trend surface to be fitted.
%              0 - horizontal plane
%              1 - planar surface
%              2 - quadratic surface
%              etc ...
%    spacing - Optional subsampling interval of points selected from img used
%              to fit the trend.  Defaults to 10.
%
% Returns:
%     newimg - Input image with trend removed.
%      trend - The fitted trend surface.
%       coef - Coefficients of polynomial surface.
%              See POLYFIT2D and POLYVAL2D for the interpretation of the
%              coefficients. Note that x and y correspond to column and row
%              numbers in img repectively.
%
% It is assumed that NaN values in the input grid represent missing/undefined
% values.
%
% See also: POLYFIT2D, POLYVAL2D

% Copyright (c) 2017 Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% peter.kovesi at uwa edu au
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

% PK December 2017

function [newimg, trend, coef] = removetrend(img, order, spacing)
    
    if ~exist('spacing', 'var'), spacing = 10; end
    
    % Extract x, y, z values from img at desired decimation
    [rows,cols] = size(img);
    [c, r] = meshgrid(1:cols, 1:rows);
    
    x =   c(1:spacing:end, 1:spacing:end);
    y =   r(1:spacing:end, 1:spacing:end);
    z = img(1:spacing:end, 1:spacing:end);
    
    % Check for undefined values and remove prior to fitting trend surface.
    ind = find(isnan(z));
    x(ind) = [];
    y(ind) = [];
    z(ind) = [];
    
    coef = polyfit2d(x, y, z, order);
    trend = polyval2d(c, r, coef);
    newimg = img - trend;