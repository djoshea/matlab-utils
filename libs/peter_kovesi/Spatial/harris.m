% Harris - Harris corner detector
%
% Usage:                 cim = harris(im, sigma, k)
%                [cim, r, c] = harris(im, sigma, k, keyword-value options...)
%
% Required arguments:   
%            im    - Image to be processed.
%            sigma - Standard deviation of smoothing Gaussian used to sum
%                    the derivatives when forming the structure tensor. Typical
%                    values to use might be 1-3.
%            k     - Parameter relating the trace to the determinant of the
%                    structure tensor in the Harris measure. 
%                    cim = det(M) - k trace^2(M). 
%                    Traditionally k = 0.04
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
% With only 'im' 'sigma' and 'k' supplied as arguments only 'cim' is returned
% as a raw corner strength image.  You may then want to look at the values
% within 'cim' to determine the appropriate threshold value to use. Note that
% the Harris corner strength varies with the intensity gradient raised to the
% 4th power.  Small changes in input image contrast result in huge changes in
% the appropriate threshold.
%
% If any of the optional keyword - value arguments for performing non-maxima
% suppression are specified then the feature coordinate locations are also
% returned.
%
% Example: To get the 100 strongest features and display the detected points
% on the input image use:
%  >> [cim, r, c] = harris(im, 1, .04, 'N', 100, 'display', true);
%
% The Harris measure is det(M) - k trace^2(M), where k is a parameter you have
% to set (traditionally k = 0.04) and M is the structure tensor.  Use Noble's
% measure if you wish to avoid the need to set a parameter k.  However the
% Shi-Tomasi measure is probably what you really want.
%
% See also: NOBLE, SHI_TOMASI, HESSIANFEATURES, NONMAXSUPPTS, DERIVATIVE5

% References: 
% C.G. Harris and M.J. Stephens. "A combined corner and edge detector", 
% Proceedings Fourth Alvey Vision Conference, Manchester.
% pp 147-151, 1988.

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
% January  2016 - Noble made distinct from the Harris function and argument
%                 handling changed (this will break some code, sorry)

function [cim, r, c] = harris(im, sigma, k, varargin)
    
    if ~isa(im,'double')
	im = double(im);
    end

    % Compute derivatives and the elements of the structure tensor.
    [Ix, Iy] = derivative5(im, 'x', 'y');
    Ix2 = gaussfilt(Ix.^2,  sigma);
    Iy2 = gaussfilt(Iy.^2,  sigma);    
    Ixy = gaussfilt(Ix.*Iy, sigma);    

    % Compute Harris corner measure. 
    cim = (Ix2.*Iy2 - Ixy.^2) - k*(Ix2 + Iy2).^2; 

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
    addParameter(p, 'display',  false, @islogical);  

    parse(p, v{:});
    
    thresh   = p.Results.thresh;
    radius   = p.Results.radius;
    N        = p.Results.N;
    subpixel = p.Results.subpixel;
    disp     = p.Results.display;    
