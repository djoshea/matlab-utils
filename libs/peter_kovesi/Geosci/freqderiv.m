% FREQDERIV - Derivatives computed via the frequency domain.
%
% Usage: [dx, dy, dv] = freqderiv(im, hx, hy, order, padding)
%
% Arguments:  
%         im - Input potential field image/grid.
%     hx, hy - Grid element size, defaults to 1, 1
%      order - Order of derivative 1st 2nd etc. Defaults to 1. 
%              The order can be fractional if you wish, say, 1.5
%    padding - Width of tapered padding to apply to the image to reduce 
%              edge effects. Defaults to 0.
%
% Returns: 
%     dx, dy - Horizontal derivatives.
%         dv - The vertical derivative.
%
% Filtering is done in the frequency domain whereby the Fourier transforms of
% the filtered images F(DX) and F(DV) is obtained from the Fourier transform of
% the input image F(U) using:
%      F(DX) =  F(U) * (2*pi*i*u)^order
%      F(DV) =  F(U) * (2*pi*sqrt(u^2 + v^2))^order
% where u and v are the spatial frequencies in x and y over the input grid.
%
% References:  
% Richard Blakely, "Potential Theory in Gravity and Magnetic Applications"
% Cambridge University Press, 1996. pp 324-326.
%
% See also: TILTDERIV, ANALYTICSIGNAL, WAVENUMBERGRID

% Copyright (c) 2017 Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% peterkovesi.com
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.
%
% October 2017

function [dx, dy, dv] = freqderiv(im, hx, hy, order, padding)

    if ~exist('hx', 'var'), hx = 1;  end
    if ~exist('hy', 'var'), hy = 1;  end
    if ~exist('order', 'var'), order = 1;  end
    if ~exist('padding', 'var')
        padding = 0; 
    else
        im = impad(im, padding, 'cosine');    
    end    
    
    [rows,cols,chan] = size(im);
    assert(chan == 1, 'Image must be single channel');
    assert(order >= 0, 'Derivative order must be >= 0');

    mask = ~isnan(im); 
    
    IM = fft2(fillnan(im)); 
    
    % Generate horizontal and vertical spatial frequency grids
    [k, kx, ky] = wavenumbergrid(rows, cols, hx, hy);

    % Form the filter by raising the frequency magnitude to the desired power,
    % then multiply by the Fourier transform of the image, invert the Fourier
    % transform, and finally mask out any NaN regions from the input image.
    if padding
        dx = imtrim(real(ifft2(IM .* (i*kx).^order)) .* double(mask), padding);
        dy = imtrim(real(ifft2(IM .* (i*ky).^order)) .* double(mask), padding);
        dv = imtrim(real(ifft2(IM .* (k).^order)) .* double(mask), padding);
    else
        dx = real(ifft2(IM .* (i*kx).^order)) .* double(mask);
        dy = real(ifft2(IM .* (i*ky).^order)) .* double(mask);
        dv = real(ifft2(IM .* (k).^order)) .* double(mask);
    end
    
    
