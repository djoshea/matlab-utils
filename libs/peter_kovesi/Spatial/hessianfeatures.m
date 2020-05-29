% HESSIANFEATURES  - Computes determiant of hessian features in an image.
%
% Usage: hdet = hessianfeatures(im, sigma)
%
% Arguments:
%             im       - Greyscale image to be processed.
%             sigma    - Defines smoothing scale.
%
% Returns:    hdet     - Matrix of determinants of Hessian
%
% The local maxima of hdet tend to mark the centres of dark or light blobs.
% However, the point that gets localised can be dependent on scale.  If the
% blobs you wish to detect are large you will need to use a value of sigma that
% is comparable in magnitude.
%
% The local minima of hdet is useful for marking the intersection points of a
% camera calibration checkerbaord pattern.  These saddle features seem to be
% more stable under scale variations.
%
% For example to get the 100 strongest saddle features in image 'im' use:
% >> hdet = hessianfeatures(im, 1);    % sigma = 1
% >> [r, c] = nonmaxsuppts(-hdet, 'N', 100);
%
% See also: HARRIS, NOBLE, SHI_TOMASI, DERIVATIVE5, NONMAXSUPPTS

% Copyright (c) 2007-2016 Peter Kovesi
% www.peterkovesi.com/matlabfns/
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

% PK Oct 2007   - Original version
%    Sept 2015  - Cleanup, scaled Harris removed.
%    Sept 2015  - Removed calculation of trace/LoG to reduce memory use
%    Jan  2016  - Made single scale. See HESSAINFEATUREMULTISCALE instead
%                 Derivative calulation change to use DERIVATIVE5

function  hdet = hessianfeatures(im, sigma)

    if ndims(im) == 3
        warning('Input image is colour, converting to greyscale')
        im = rgb2gray(im); 
    end

    if ~isa(im,'double')
	im = double(im);
    end    
    
    if sigma > 0    % Convolve with Gaussian at desired sigma
        sze = ceil(7*sigma);
        if ~mod(sze,2)   % ensure size is odd
            sze = sze+1;
        end
        G = fspecial('gaussian', sze, sigma);
        Gim = filter2(G, im);
    
    else            % No smoothing
        Gim = im;
        sigma = 1;  % Needed for normalisation later
    end
    
    % Take 1st and 2nd derivatives in x and y
    [Lx, Ly, Lxx, Lxy, Lyy] = derivative5(Gim, 'x', 'y', 'xx', 'xy', 'yy');
    
    % Apply normalizing scaling factor of sigma to 1st derivatives and
    % sigma^2 to 2nd derivatives        
    Lx = Lx*sigma;
    Ly = Ly*sigma;
    Lxx = Lxx*sigma^2; 
    Lyy = Lyy*sigma^2;                
    Lxy = Lxy*sigma^2;        
    
    % Determinant
    hdet = Lxx.*Lyy - Lxy.^2;

    
