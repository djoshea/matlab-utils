% SHI_TOMASI - Shi - Tomasi corner detector
%
% Usage:                 cim = shi_tomasi(im, sigma)
%                [cim, r, c] = shi_tomasi(im, sigma, keyword-value options...)
%
% Required arguments:   
%            im    - Image to be processed.
%            sigma - Standard deviation of smoothing Gaussian used to sum
%                    the derivatives when forming the structure tensor. Typical
%                    values to use might be 1-3.
%
% Optional keyword - value arguments for performing non-maxima suppression:
%
%          'radius' - Radius of region considered in non-maximal
%                     suppression. Typical values to use might
%                     be 1-3 pixels. Default is 1.
%          'thresh' - Threshold, only features with value greater than
%                     threshold are returned. Default is 1.
%          'N'      - Maximum number of features to return.  In this case the
%                     N strongest features with value above 'thresh' are
%                     returned. Default is Inf.
%        'subpixel' - If set to true features are localised to subpixel
%                     precision. Default is false.
%        'display'  - Optional flag true/false. If true the detected corners
%                     are overlayed on the input image. This can be useful
%                     for parameter tuning. Default is false.
%
% Returns:
%            cim    - Corner strength image.
%            r      - Row coordinates of corner points.
%            c      - Column coordinates of corner points.
%
% With only 'im' and 'sigma' supplied as arguments only 'cim' is returned
% as a raw corner strength image.  You may then want to look at the values
% within 'cim' to determine the appropriate threshold value to use. 
%
% If any of the optional keyword - value arguments for performing non-maxima
% suppression are specified then the feature coordinate locations are also
% returned.
%
% Example: To get the 100 strongest features and display the detected points
% on the input image use:
%  >> [cim, r, c] = shi_tomasi(im, 1, 'N', 100, 'display', true);
%
% The Shi - Tomasi measure returns the minimum eigenvalue of the structure
% tensor.  This represents the ideal that the Harris and Noble detectors attempt
% to approximate.  Back in 1988 Harris wanted to avoid the computational cost of
% taking a square root when computing features.  This is no longer relevant
% today!
%
% See also: HARRIS, NOBLE, HESSIANFEATURES, NONMAXSUPPTS, DERIVATIVE5

% Reference: 
% J. Shi and C. Tomasi. "Good Features to Track,". 9th IEEE Conference on
% Computer Vision and Pattern Recognition. 1994.

% Copyright (c) 2016 Peter Kovesi
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

% January 2016 - Original version

function [cim, r, c] = shi_tomasi(im, sigma, varargin)
    
    if ~isa(im,'double')
	im = double(im);
    end

    % Compute derivatives and the elements of the structure tensor.
    [Ix, Iy] = derivative5(im, 'x', 'y');
    Ix2 = gaussfilt(Ix.^2,  sigma);
    Iy2 = gaussfilt(Iy.^2,  sigma);    
    Ixy = gaussfilt(Ix.*Iy, sigma);    

    T = Ix2 + Iy2;                 % trace
    D = Ix2.*Iy2 - Ixy.^2;         % determinant
    
    % The two eigenvalues of the 2x2 structure tensor are:
    % L1 = T/2 + sqrt(T.^2/4 - D)
    % L2 = T/2 - sqrt(T.^2/4 - D)

    % We just want the minimum eigenvalue
    cim = T/2 - sqrt(T.^2/4 - D);
    
    if ~isempty(varargin)
        [thresh, radius, N, subpixel, disp] = checkargs(varargin);
        if disp
            [r,c] = nonmaxsuppts(cim, 'thresh', thresh, 'radius', radius, 'N', N, ...
                                 'subpixel', subpixel, 'im', im);
        else
            [r,c] = nonmaxsuppts(cim, 'thresh', thresh, 'radius', radius, 'N', N, ...
                                 'subpixel', subpixel, 'im', []);
        end
    else
        r = [];
        c = [];
    end
    
%---------------------------------------------------------------
function [thresh, radius, N, subpixel, display] = checkargs(v)
    
    p = inputParser;
    p.CaseSensitive = false;
    
    % Define optional parameter-value pairs and their defaults    
    addParameter(p, 'thresh',       0, @isnumeric);  
    addParameter(p, 'radius',       1, @isnumeric);  
    addParameter(p, 'N',          Inf, @isnumeric);  
    addParameter(p, 'subpixel', false, @islogical);  
    addParameter(p, 'display',  false, @islogical);  

    parse(p, v{:});
    
    thresh   = p.Results.thresh;
    radius   = p.Results.radius;
    N        = p.Results.N;
    subpixel = p.Results.subpixel;
    display  = p.Results.display;
