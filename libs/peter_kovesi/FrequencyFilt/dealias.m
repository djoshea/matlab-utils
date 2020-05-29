% DEALIAS - Filter image to try to remove aliasing artifacts
%
% Usage: newimg = dealias(img, cx, cy, n, padding, periodic)
%
% Arguments:  
%        img - Image to be processed.
%     cx, cy - Cutoff frequencies for the x and y directions.  Suggested
%              values for each is around 0.4 - 0.45
%          n - Optional order of Butterworth filter. Defaults to 20. Reduce
%              this if your image has very sharp features and you find that
%              the filtered image has ringing artifacts.
%    padding - Width of tapered padding to apply to the image to reduce
%              edge effects. Depending on the degree of cyclic discontinuity
%              in your data values of up to, say, 10 can be useful. 
%              While it defaults to 0 some padding is strongly recommended.
%   periodic - Boolean flag indicating whether to use the periodic fft in
%              lieu of, or in addition to, padding.  I am not sure of the 
%              value of this.  Defaults to false.
%
% Returns:
%     newimg - Filtered image.
%
%
% This function performs low pass filtering on an image with the aim of just
% clipping out the high frequency gridding artifacts in x and/or y leaving the
% rest of the image intact.  Accordingly the cutoff frequencies should be high,
% close to the Nyquist frequency of 0.5, and the order of the filter should be
% high so that the cutoff is sharp.  If filtering is only needed in one
% direction then set the other cutoff frequency to a high value, say 1, so that
% no filtering occurs in that direction.
%
% To achieve this kind of filtering the filter is constructed from the product
% of two low-pass Butterworth filters. One filter cuts out high frequency
% components in the x direction and the other in the y direction.  The
% assumption being that the aliasing pattern is a result of the gridding used to
% form the image.  
%
% See also: PERFFT2, LOWPASSFILTER, FILTERGRID

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

% PK September 2017
%    December  2017 - Changed to cosine padding

function newimg = dealias(im, cx, cy, n, padding, periodic)

    if ~exist('n', 'var'), n = 20; end
    if ~exist('padding', 'var'), padding = 0; end
    if ~exist('periodic', 'var'), periodic = false; end

    img = impad(im, padding, 'cosine');
    
    % Construct filter in the frequency domain
    [~, u1, u2] = filtergrid(size(img));

    % The two low-pass filters in x and y are defined as follows:
    %    f1 = 1.0 ./ (1.0 + (u1 ./ cx).^(2*n)); 
    %    f2 = 1.0 ./ (1.0 + (u2 ./ cy).^(2*n)); 
    %    f = f1.*f2;
    f = 1.0 ./ ((1.0 + (u1 ./ cx).^(2*n)) .* (1.0 + (u2 ./ cy).^(2*n)));
    
    if periodic % Use periodic FFT
        IMG = perfft2(img);
    else
        IMG = fft2(img);
    end

    % Apply the filter and trim any padding
    newimg = imtrim(real(ifft2(IMG.*f)), padding);
