% VERTDERIVATIVEINTEGRAL  Vertical derivative or integral of potential field data
%
% Usage: vd = vertderivativeintegral(im, order, hx, hy, padding)
%
% Arguments:  im - Input potential field image.
%          order - Order of derivative/integral
%                  +ve values result in derivatives 1st 2nd etc. 
%                  -ve values result in integrals.
%                  The order can be fractional if you wish, say, 1.5 or -0.5
%         hx, hy - Grid element size, defaults to 1, 1
%        padding - Width of tapered padding to apply to the image to reduce 
%                  edge effects. Defaults to 0.
%
% Returns:    v - The vertical derivative/integral.
%
% Vertical derivative/integral filtering is done in the frequency domain whereby
% the Fourier transform of the filtered image F(V) is obtained from the Fourier
% transform of the input image F(U) using
%      F(V) =  F(U) * (2*pi*sqrt(u^2 + v^2))^order
% where u and v are the spatial frequencies in x and y over the input grid.
%
% Reference:  
% Richard Blakely, "Potential Theory in Gravity and Magnetic Applications"
% Cambridge University Press, 1996. pp 324-326.
%
% See also: TILTDERIV, ANALYTICSIGNAL, FREQDERIV, HORIZDERIV

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
% November 2017 - generalized from VERTDERIV

function  v = vertderivativeintegral(im, order, hx, hy, padding)
    
    if ~exist('hx', 'var'), hx = 1;  end
    if ~exist('hy', 'var'), hy = 1;  end
    if ~exist('padding', 'var')
        padding = 0; 
    else
        im = impad(im, padding, 'cosine');    
    end
    
    [rows,cols,chan] = size(im);
    assert(chan == 1, 'Image must be single channel');

    mask = ~isnan(im); 
    IM = fft2(fillnan(im)); 
    
    k = wavenumbergrid(rows, cols, hx, hy);   
    
    % Construct filter by raising the frequency magnitude to the desired power.
    k(1,1) = 1;       % Avoid divide by zero if order is -ve
    filter = k.^order;
    filter(1,1) = 0;  % Ensure 0 DC
    
    % Apply filter, invert the Fourier transform, and finally mask out any NaN
    % regions from the input image.
    if padding
        v = imtrim(real(ifft2(IM .* filter)) .* double(mask), padding);
    else
        v = real(ifft2(IM .* filter)) .* double(mask);
    end
    
