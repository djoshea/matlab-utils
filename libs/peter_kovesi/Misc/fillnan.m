% FILLNAN  - fills NaN values in an image with closest non Nan value
%
% NaN values in an image are replaced with the value in the closest pixel that
% is not a NaN.  This can be used as a crude (but quick) 'inpainting' function
% to allow a FFT to be computed on an image containing NaN values.  While the
% 'inpainting' is very crude it is typically good enough to remove most of the
% edge effects one might get at the boundaries of the NaN regions.  The NaN
% regions should then be remasked out of the final processed image.
%
% Usage:  [newim, mask] = fillnan(im);
%
%   Argument:  im    - Image to be 'filled'
%   Returns:   newim - Filled image
%              mask  - Binary image indicating NaN regions in the original
%                      image.
%
% See Also: REMOVENAN

% Copyright (c) 2007 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

function [newim, mask] = fillnan(im);
    
    % Generate distance transform from non NaN regions of the image. 
    % L will contain indices of closest non NaN points in the image
    mask = ~isnan(im);   
    
    if all(isnan(im(:)))
        newim = im;
        warning('All elements are NaN, no filling possible.');
        return
    end
    
    [~,L] = bwdist(mask);   
    
    ind = find(isnan(im));  % Indices of points that are NaN
    
    % Fill NaN locations with value of closest non NaN pixel
    newim = im;
    newim(ind) = im(L(ind));

    
    