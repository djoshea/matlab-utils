% VERTDERIV  Vertical derivative of potential field data
%
% Usage: vd = vertderiv(im, order, padding)
%
% Arguments:  im - Input potential field image.
%          order - Order of derivative 1st 2nd etc. Defaults to 1. 
%                  The order can be fractional if you wish, say, 1.5
%        padding - Width of tapered padding to apply to the image to reduce 
%                  edge effects. Defaults to 0.
%
% Returns:    vd - The vertical derivative.
%
% Vertical derivative filtering is done in the frequency domain whereby the
% Fourier transform of the filtered image F(VD) is obtained from the
% Fourier transform of the input image F(U) using
%      F(VD) =  F(U) * (2*pi*sqrt(u^2 + v^2))^order
% where u and v are the spatial frequencies in x and y over the input grid.
%
% References:  
% Richard Blakely, "Potential Theory in Gravity and Magnetic Applications"
% Cambridge University Press, 1996. pp 324-326.
%
% See also: TILTDERIV, HORIZDERIV

% Copyright (c) 2015-2017 Peter Kovesi
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
% March   2015  
% October 2017 - Cleaned up, added padding option

function  vd = vertderiv(im, order, padding)

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
    [radius, u1, u2] = filtergrid(rows, cols);    

    % Form the filter by raising the frequency magnitude to the desired power,
    % then multiply by the Fourier transform of the image, invert the Fourier
    % transform, and finally mask out any NaN regions from the input image.
    % Note we multiply the filter by 2pi to obtain a scaling that correspnds
    % to a spatial derivative
    if padding
        vd = imtrim(real(ifft2(IM .* (2*pi*radius).^order)) .* double(mask), padding);
    else
        vd = real(ifft2(IM .* (2*pi*radius).^order)) .* double(mask);
    end
    
