% HORIZDERIV  Horizontal derivatives of 2D image
%
% Usage: [hdx, hdy] = horizderiv(im, order, padding)
%
% Arguments:  im - Input potential field image.
%          order - Order of derivative 1st 2nd etc. Defaults to 1. 
%                  The order can be fractional if you wish, say, 1.5
%        padding - Width of tapered padding to apply to the image to reduce 
%                  edge effects. Defaults to 0.
%
% Returns: hdx, hdy - The horizontal derivatives.
%
% Derivative filtering is done in the frequency domain whereby the
% Fourier transform of the filtered image F(HDX) is obtained from the
% Fourier transform of the input image F(IM) using
%      F(HDX) =  F(IM) * 2*pi*i*u^order
% where u and v are the spatial frequencies in x and y over the input grid.
%
% References:  
% Richard Blakely, "Potential Theory in Gravity and Magnetic Applications"
% Cambridge University Press, 1996. pp 324-326.
%
% See also: VERTDERIV, TILTDERIV

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
%
% October 2017

function  [hdx, hdy] = horizderiv(im, order, padding)

    if ~exist('order', 'var'), order = 1;  end
    if ~exist('padding', 'var')
        padding = 0; 
    else
        im = impad(im, padding, 'taper');    
    end    
    
    [rows,cols,chan] = size(im);
    assert(chan == 1, 'Image must be single channel');
    assert(order >= 0, 'Derivative order must be >= 0');

    mask = ~isnan(im); 
    
    IM = fft2(fillnan(im)); 
    
    % Generate horizontal and vertical frequency grids that vary from -0.5 to
    % 0.5.  This represents spatial frequency in grid units.
    [radius, u, v] = filtergrid(rows, cols);    

    % Form the filter by raising the frequency magnitude to the desired power,
    % then multiply by the Fourier transform of the image, invert the Fourier
    % transform, and finally mask out any NaN regions from the input image.
    % Note we multiply the filter by 2pi to obtain a scaling that corresponds
    % to a spatial derivative obtained by finite differences.
    if padding
        hdx =  imtrim(real(ifft2(IM .* (2*pi*i*u).^order)) .* double(mask), padding);
        hdy =  imtrim(real(ifft2(IM .* (2*pi*i*v).^order)) .* double(mask), padding);
    else
        hdx =  real(ifft2(IM .* (2*pi*i*u).^order)) .* double(mask);
        hdy =  real(ifft2(IM .* (2*pi*i*v).^order)) .* double(mask);
    end
    
