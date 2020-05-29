% UPWARDCONTINUE  Upward continuation for magnetic or gravity potential field data
%
% Usage: [up, psf] = upwardcontinue(im, h, dx, dy, padding)
%
% Arguments:  im - Input potential field image
%              h - Height to upward continue to (+ve)
%         dx, dy - Grid spacing in x and y.  The upward continuation height
%                  is computed relative to the grid spacing.  If omitted dx =
%                  dy = 1, that is, the value of h is in grid spacing units.
%                  If dy is omitted it is assumed dy = dx. 
%        padding - Width of tapered padding to apply to the image to reduce 
%                  edge effects. Defaults to 0.
%
% Returns:    up - The upward continued field image
%            psf - The point spread function corresponding to the upward
%                  continuation height.
%
% Upward continuation filtering is done in the frequency domain whereby the
% Fourier transform of the upward continued image F(Up) is obtained from the
% Fourier transform of the input image F(U) using
%      F(Up) = e^(-2*pi*h * sqrt(u^2 + v^2)) * F(U)
% where u and v are the spatial frequencies over the input grid.
%
% To minimise edge effect problems Moisan's Periodic FFT is used.  This avoids
% the need for data tapering.  
%
% Reference:  
% Richard Blakely, "Potential Theory in Gravity and Magnetic Applications"
% Cambridge University Press, 1996, pp 315-319

% Copyright (c) 2012-2017 Peter Kovesi
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
% June 2012    - Original version.
% June 2014    - Tidied up and documented.
% August 2014  - Smooth, non periodic component of orginal image added back to
%                filtered result so that calculation of residual against the
%                original image is facilitated.
% October 2017 - Changed to use filtergrid(), decided against the use of
%                perfft2 and added padding option instead.

function  [up, psf] = upwardcontinue(im, h, dx, dy, padding)

    if ~exist('dx', 'var'), dx = 1;  end
    if ~exist('dy', 'var'), dy = dx; end
    if ~exist('padding', 'var')
        padding = 0; 
    else
        im = impad(im, padding, 'taper');    
    end

    [rows,cols,chan] = size(im);
    assert(chan == 1, 'Image must be single channel');
    mask = ~isnan(im); 

    IM = fft2(fillnan(im));
        
    % Generate horizontal and vertical frequency grids that vary from
    % -0.5 to 0.5 
    [~, u1, u2] = filtergrid(rows,cols);
    
    % Divide by grid size in each dimension to get correct spatial frequencies.
    u1 = u1/dx; 
    u2 = u2/dy;

    freq = sqrt(u1.^2 + u2.^2); % Matrix values contain spatial frequency
                                % values as a radius from centre (but
                                % quadrant shifted).
                                
    % Continuation filter in the frequency domain.
    W = exp(-2*pi*h*freq);
    
    % Apply filter to obtain upward continuation and apply mask corresponding to
    % NaN values.  Also reconstruct the spatial representation of the point
    % spread function corresponding to the upward continuation height.
    if padding
        up = imtrim(real(ifft2(IM.*W)) .* double(mask), padding);
        psf = imtrim(real(fftshift(ifft2(W))), padding);
    else
        up = real(ifft2(IM.*W)) .* double(mask);
        psf = real(fftshift(ifft2(W)));
    end
    

