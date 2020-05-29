% TILTDERIV  Tilt derivative of potential field data
%
% Usage: td = tiltderiv(im, hx, hy, padding)
%
% Arguments:    im - Input potential field image.
%           hx, hy - Grid element size, defaults to 1, 1
%          padding - Width of tapered padding to apply to the image to reduce 
%                    edge effects. Depending on the degree of cyclic
%                    discontinuity in your data values of up to, say, 100
%                    can be useful. Defaults to 50.
%
% Returns:      td - The tilt derivative.
%
% Reference:  
% Hugh G. Miller and Vijay Singh. Potential field tilt - a new concept for
% location of potential field sources. Applied Geophysics (32) 1994. pp
% 213-217.
%
% See also: ANALYTICSIGNAL, FREQDERIV, DEALIAS

% Copyright (c) 2015-2017 Peter Kovesi
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
% March    2015  
% October  2017 - Changed to use frequency domain horizontal derivatives and
%                 to allow for data padding. Specify hx, hy.
% December 2017 - Incorporate dealiasing/lowpass filtering after the padding.
%                 Unwrapped code to avoid repeated FFT operations

function  td = tiltderiv(im, hx, hy, padding)

    assert(size(im,3) == 1, 'Image must be single channel');
    if ~exist('hx', 'var') && ~exist('hy', 'var'), hx = 1; hy = 1;  end
    if ~exist('padding', 'var'), padding = 50; end
    
    mask = ~isnan(im); 
    im = impad(fillnan(im), padding, 'cosine');
    IM = fft2(im); 
    
    % After padding the data it is almost essential to apply a low pass
    % filter with a high cut off to avoid artifacts propagating into the
    % images.  The tilt derivative can be quite 'delicate' in this regard.
    %
    % The filter is constructed from the product of two low-pass Butterworth
    % filters. One filter cuts out high frequency components in the x direction
    % and the other in the y direction.  The assumption being that image
    % artifacts are a result of the gridding used to form the image. Also,
    % the padding process, while made as smooth as possible cyclically,
    % introduces high frequency content in the padded regions perpendicular
    % to the image edges.  I believe this causes artifacts in the tilt
    % derivative if they are not filtered.
    
    % The two low-pass filters in x and y are defined as follows:
    %    f1 = 1.0 ./ (1.0 + (ux ./ cx).^(2*n)); 
    %    f2 = 1.0 ./ (1.0 + (uy ./ cy).^(2*n)); 
    %    f = f1.*f2;
    cx = 0.45; cy = 0.45; n = 15;  % Cut off at 0.45 and a high order of n
    [~, ux, uy] = filtergrid(size(im));
    f = 1.0 ./ ((1.0 + (ux ./ cx).^(2*n)) .* (1.0 + (uy ./ cy).^(2*n)));

    IM = IM.*f;  % Apply the low-pass filter to the image
    
    % Generate wavenumber grids from the filter grids
    kx = 2*pi*ux/hx;
    ky = 2*pi*uy/hy;
    k = sqrt(kx.^2 + ky.^2);
    
    % Take horizontal and vertical first derivatives and remove the padding.
    dx = imtrim(real(ifft2(IM .* (i*kx))), padding);
    dy = imtrim(real(ifft2(IM .* (i*ky))), padding);
    dv = imtrim(real(ifft2(IM .* k)), padding);

    % Finally compute the tilt derivative and mask out any NaNs that were in
    % the input image.
    td = atan(dv./(sqrt(dx.^2 + dy.^2) + eps)) .* double(mask);
