% LOGCOLOURNORMALIZATION - Chromaticity, grey, or comprehensive colour normalization.
%
% Useage: [imgcn, imgn] = logcolournormalization(img, option, scale)
%
% Arguments:
%      img - Image to be normalized
%   option - String 'comprehensive', 'chromaticity' or 'grey'/'gray', only 
%            the first 4 characters need be specified.
%            Default is 'comprehensive'
%            - 'chromaticity' performs RGB normalization on each pixel.
%               r = R/mean(R,G,B) etc
%            - 'grey' performs a 'grey world' normalization where r =
%               R/mean(R) etc. where the mean is taken over the red component
%               of all pixel in the image.  The result is supposedly
%               independent of illumination colour, however the result
%               depends on image content because the mean red, green and blue
%               values are made equal. 
%            - 'comprehensive' implements Finlayson and Xu's non-iterative 
%               comprehensive normalization which simultaneously normalizes
%               chromaticity and illumination colour.
%    scale - Optional scaling (dividing) factor. Defaults to 3.  Chromaticity
%            and grey normalization result in image values having a mean
%            close to 1. Dividing by 3 makes the result comparable to simple 
%            colour normalization where r = R/(R+B+G) where the expected value
%            is around 1/3.
% Returns:
%    imgcn - Colour normalized image of type double with values in the range 0-1.
%     imgn - Raw image rescaled to have a maximum value of 1.
%
% Reference:
% Graham Finlayson and Ruixia Xu
% Non-iterative Comprehensive Normalization
% Proc. CGIV 2002

% Copyright (c) 2017 Peter Kovesi
% Centre for Exploration Targeting
% School of Earth Sciences
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

% PK August 2017

function [imgcn, imgn] = logcolournormalization(img, option, scale)
    
    if ~exist('option', 'var'), option = 'comprehensive'; end
    if ~exist('scale', 'var'), scale = 3; end
    
    if ~(strncmpi(option, 'comprehensive', 4) || ...
         strncmpi(option, 'chromaticity',4) || ...
         strncmpi(option, 'grey',4) || ...
         strncmpi(option, 'gray',4))
        error('Unrecognized option');
    end
    
    % Normalize image to 0-1 and ignore alpha channel if it exists.
    if isa(img, 'uint8')
        imgn = double(img(:,:,1:3))/255;
    elseif isa(img, 'uint16')
        imgn = double(img(:,:,1:3))/2^16;
    elseif isa(img, 'double')        
        imgn = img./max(img(:));
    end

    zeroOffset = 0.01;               % Avoid log of 0
    imgcn = log(imgn + zeroOffset);  % Work in the log domain

    % Chromaticity normalization step. This gives invariance to lighting
    % geometry and illumination magnitude.
    if strncmpi(option, 'chromaticity',4) || ...
       strncmpi(option, 'comprehensive', 4) 
        meanv = mean(imgcn,3) + eps;
        for ch = 1:3
            imgcn(:,:,ch) = imgcn(:,:,ch) - meanv;
        end
    end

    % Grey normalization step (grey world). This gives invariance to
    % illumination colour (but the result depends on the image content).
    if strncmpi(option, 'grey',4) || ...
       strncmpi(option, 'gray',4) || ...
       strncmpi(option, 'comprehensive', 4) 
        for ch = 1:3
            tmp = imgcn(:,:,ch);
            meanch = mean(tmp(:));
%            meanch = median(tmp(:));  % Median does not make much of a difference.
            imgcn(:,:,ch) = imgcn(:,:,ch) - meanch;
        end
    end
    
    % Re-exponentiate and divide by three so that normalization is roughly
    % equivalent to dividing by (R+G+B) as per normal colour normalization    
    imgcn = (exp(imgcn)-zeroOffset)/scale;  
    
    % Clip any values above 1 (on some sensors one can get large green values)
    imgcn(imgcn > 1) = 1;    

    