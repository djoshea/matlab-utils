% ANALYITICSIGNAL  Analytic signal of potential field data
%
% Usage: A = analyticsignal(im, hx, hy padding)
%
% Arguments:    im - Input potential field image.
%           hx, hy - Grid element size, defaults to 1, 1
%          padding - Width of tapered padding to apply to the image to reduce 
%                    edge effects. Depending on the degree of cyclic
%                    discontinuity in your data values of up to, say, 100
%                    can be useful. Defaults to 0.
%
% Returns:       A - The analytic signal
%
%
% See also: TILTDERIV, FREQDERIV

% Copyright (c) Peter Kovesi
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
% March 2015  
% October 2017 - Changed to use horizderiv and added padding option

function  A = analyticsignal(im, hx, hy, padding)
    
    assert(size(im,3) == 1, 'Image must be single channel');

    if ~exist('hx', 'var'), hx = 1;  end
    if ~exist('hy', 'var'), hy = 1;  end    
    if ~exist('padding', 'var'), padding = 0; end
    im = impad(im, padding, 'cosine');
    
    order = 1;
    [dx, dy, dv] = freqderiv(im, hx, hy, order);
    
    A = imtrim(sqrt(dx.^2 + dy.^2 + dv.^2), padding);
