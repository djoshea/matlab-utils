% WAVENUMBERGRID  Generate wavenumber grid for frequency domain filtering
%
% Usage:  [k, kx, ky] = wavenumbergrid(rows, cols, dx, dy)
%         [k, kx, ky] = wavenumbergrid([rows, cols], dx, dy)
%
% Arguments:  
%    rows, cols - Size of grid.
%        dx, dy - Optional specification of grid element sizes. 
%                 Defaults to 1, 1.
%
% Returns:        
%            k - Grid of size [rows cols] of wavenumber values, where 
%                k = sqrt(kx^2 + ky^2). 
%                Grid is quadrant shifted so that 0 frequency is at k(1,1)
%       kx, ky - Grids containing wavenumber values in the x and y directions
%                where kx = 2*pi*ux/dx  and ux, uy are normalised frequency
%                values ranging from -0.5 to 0.5 in x and y directions
%                respectively. kx and ky are quadrant shifted.
%
% Note, depending on the filter you are constructing, you may want to set
% k(1,1), the zero frequency component, to 1.0 to avoid any divide by zero
% problems when constructing filters.
%
% See also: FILTERGRID

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
%
% October 2017

function [k, kx, ky] = wavenumbergrid(varargin)

    [rows, cols, dx, dy] = parseinputs(varargin{:});
    
    % Set up X and Y spatial frequency matrices, ux and uy The following code
    % adjusts things appropriately for odd and even values of rows and columns
    % so that the 0 frequency point is placed appropriately.  See
    % https://blogs.uoregon.edu/seis/wiki/unpacking-the-matlab-fft/
    if mod(cols,2)
        uxrange = [-(cols-1)/2:(cols-1)/2]/cols;
    else
        uxrange = [-cols/2:(cols/2-1)]/cols; 
    end
    
    if mod(rows,2)
        uyrange = [-(rows-1)/2:(rows-1)/2]/rows;
    else
        uyrange = [-rows/2:(rows/2-1)]/rows; 
    end
    
    [ux,uy] = meshgrid(uxrange, uyrange);
    
    % Quadrant shift so that filters are constructed with 0 frequency at
    % the corners
    ux = ifftshift(ux);
    uy = ifftshift(uy);
    
    % Divide normalised spatial frequencies by the grid size to get dimensional
    % spatial frequencies, and multiply by 2pi to get wavenumber.
    kx = 2*pi*ux/dx;
    ky = 2*pi*uy/dy;
    k = sqrt(kx.^2 + ky.^2);

%---------------------------------------------------------                   
function [rows,cols,dx,dy] = parseinputs(varargin)

    dx = 1;
    dy = 1;
    
    if length(varargin{1}) == 2  % [rows, cols] is a vector
        rows = varargin{1}(1);
        cols = varargin{1}(2);
        if length(varargin) == 3
            dx = varargin{2};
            dy = varargin{3};
        end
    
    else                         % rows, cols specified separately
        rows = varargin{1};
        cols = varargin{2};
        if length(varargin) == 4
            dx = varargin{3};
            dy = varargin{4};
        end
    end
    
    
