% NOBLE - Noble's corner detector
%
% Usage:                 cim = noble(im, sigma)
%                [cim, r, c] = noble(im, sigma, keyword-value options...)
%
% Required arguments:   
%            im     - Image to be processed.
%            sigma  - Standard deviation of smoothing Gaussian used to sum
%                     the derivatives when forming the structure tensor. Typical
%                     values to use might be 1-3.
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
% With only 'im' and 'sigma' supplied as arguments only 'cim' is returned as a
% raw corner strength image.  You may then want to look at the values within
% 'cim' to determine the appropriate threshold value to use. Note that the Noble
% and Harris corner strength varies with the intensity gradient raised to the
% 4th power.  Small changes in input image contrast result in huge changes in
% the appropriate threshold.
%
% If any of the optional keyword - value arguments for performing non-maxima
% suppression are specified then the feature coordinate locations are also
% returned.
%
% Example: To get the 100 strongest features and display the detected points
% on the input image use:
%  >> [cim, r, c] = noble(im, 1, 'N', 100, 'display', true);
%
% Note that Noble's corner measure is det(M)/trace(M) where M is the stucture
% tensor.  In comparision, the Harris measure is det(M) - k trace^2(M), where k
% is a parameter you have to set (traditionally k = 0.04).  Noble's measure
% avoids the need to set a parameter k and to my mind is much more satisfactory.
% However the Shi-Tomasi measure is probably what one really wants.
%
% See also: HARRIS, SHI_TOMASI, HESSIANFEATURES, NONMAXSUPPTS, DERIVATIVE5

% References: 
% C.G. Harris and M.J. Stephens. "A combined corner and edge detector", 
% Proceedings Fourth Alvey Vision Conference, Manchester.
% pp 147-151, 1988.
%
% Alison Noble, "Descriptions of Image Surfaces", PhD thesis, Department
% of Engineering Science, Oxford University 1989, p45.

% Copyright (c) 2002-2016 Peter Kovesi
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

% March    2002 - Original version
% December 2002 - Updated comments
% August   2005 - Changed so that code calls nonmaxsuppts
% August   2010 - Changed to use Farid and Simoncelli's derivative filters
% January  2016 - Noble made distinct from the Harris function

function [cim, r, c] = noble(im, sigma, varargin)
    
    if ~isa(im,'double')
	im = double(im);
    end

    % Compute derivatives and the elements of the structure tensor.
    [Ix, Iy] = derivative5(im, 'x', 'y');
    Ix2 = gaussfilt(Ix.^2,  sigma);
    Iy2 = gaussfilt(Iy.^2,  sigma);    
    Ixy = gaussfilt(Ix.*Iy, sigma);    

    % Compute Noble's corner measure. 
    cim = (Ix2.*Iy2 - Ixy.^2)./(Ix2 + Iy2 + eps); 

    if length(varargin) > 0
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
function [thresh, radius, N, subpixel, disp] = checkargs(v)
    
    p = inputParser;
    p.CaseSensitive = false;
    
    % Define optional parameter-value pairs and their defaults    
    addParameter(p, 'thresh',       0, @isnumeric);  
    addParameter(p, 'radius',       1, @isnumeric);  
    addParameter(p, 'N',          Inf, @isnumeric);  
    addParameter(p, 'subpixel', false, @islogical);  
    addParameter(p, 'display',     false, @islogical);  

    parse(p, v{:});
    
    thresh   = p.Results.thresh;
    radius   = p.Results.radius;
    N        = p.Results.N;
    subpixel = p.Results.subpixel;
    disp     = p.Results.display;    
