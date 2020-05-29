% TERRACE - Terracing operator for potential field data.
%
% Useage: terrimg = terrace(img, nIter, sigma)
%
% Arguments:
%       img - Input image to be terraced
%     nIter - Number of iterations. This controls the degree of
%             terracing. Values from 1 to 20 are useful.  Small values can
%             be used to provide a simple sharpening effect.
%     sigma - Standard deviation of Laplacian of Gaussian used to compute the
%             2nd derivatives.  This controls the scale of analysis.  Large
%             values will result in small features being smoothed out.  Try
%             values from 1 to 5. Typically small values are better.
%
% Returns:
%   terrimg - Terraced image.
%
%
% This implementation differs from that suggested by Cordell and McCafferty
% and by Cooper and Cowan in two ways:
%
% 1) The curvature/second derivative information is fixed at the values computed
% from the original image.  It is not recomputed on each iteration as this is
% highly unstable and leads to anomalous 'ripples' in the output.  Such ripples
% can be seen in figures 4 and 5 of Cooper and Cowan's paper.  The key attribute
% of this code is that the output remains stable no matter how many iterations
% are applied.
%
% 2) Curvature is not computed, all that is required is the 2nd derivative.  If
% the 2nd derivative is +ve then curvature will be +ve and vice-versa.  The
% Laplacian of Gaussian used to compute 2nd derivatives, the standard deviation
% can be used to control the scale of analysis.

% References:
%
% Cordell L. and McCafferty A.E. 1989. A terracing operator for physical
% property mapping with potential field data. Geophysics 54, 621–634.
%
% G.R.J. Cooper and D.R. Cowan ASEG 2009. "Terracing potential field data"

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

function terrimg = terrace(img, nIter, sigma)

    % Structuring element for determining local min and max value. (Note a
    % large circular structuring element can be used in which case fewer
    % iterations are needed. However I think things are more 'stable' with a
    % small SE)
    se = strel('square',3);
    terrimg = img;
    
    % Generate Laplacian of Gaussian filter and apply to image.
    sze = ceil(8*sigma);
    if ~mod(sze,2), sze = sze+1;  end
    h = fspecial('log', sze, sigma);
 
    log = filter2(h, terrimg);    
    
    % Iterate to sharpen points of maximum gradient and flatten regions into
    % terraces.
    for i = 1:nIter
        % Get min and max value in neighbourhood of each pixel
        minv = imerode(terrimg, se);
        maxv = imdilate(terrimg, se);
        
        % Replace values at a point of -ve 2nd derivative with the max value in
        % the local neighbourhood.  Vice-versa for points with +ve 2nd derivative.
        ind = find(log < 0);
        terrimg(ind) = maxv(ind);
        
        ind = find(log > 0);
        terrimg(ind) = minv(ind);
    end
    