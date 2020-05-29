% ORIENTATIONPLOT - Visualizes orientation image with dithered oriented lines
%
% Usage:  orientationplot(oim, 'mag', mag, 'spacing', spacing, 'fig', fig, ...
%                         'linelen', linelen, 'holdon', true/false)
%
% Required argument:
%         oim - Image of orientations (radians)
%
% Keyword-value optional arguments:
%         mag - Image with same size as 'oim' specifying the local orientation 
%               'strength' or coherence. Defaults to constant coherence of 1.
%     spacing - Subsampling grid interval to use across the orientation image. Try
%               a value of about 5 - 10 to start with. Defaults to 5.
%         fig - Figure number to use.  Default is to create a new figure.
%     linelen - Length of the oriented line segments relative to the grid spacing,
%               try values from 0.5 to 5. Defaults to 0.5.
%      holdon - If set to true the specified figure is not cleared. Defaults
%               to false.
%
% The orientation image is visualized as a set of oriented line segments with
% length proportional to the values in 'mag'.  The line segments are plotted in
% a grid pattern across the image.  The grid locations are not perfectly regular
% but instead are randomly dithered +- spacing/2 so that the grid pattern itself
% does not interfere with your perception of the orientations.  This improves
% the perception of the orientation pattern significantly.
%
% If the plot looks wrong try adding pi/2 to your orientations...
%
% See also: GABORSPECTRUMORIENTATION, GABORCONVOLVE, RIDGEORIENT, CANNY 

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

% PK May 2017

function orientationplot(varargin)
    
    [oim, mag, spacing, fig, linelen, holdon] = parseInputs(varargin{:});
    
    if isempty(fig)
        figure;
    else
        figure(fig)
    end
    
    subplot('position',[0 0 1 1]); % Use the whole window
    
    % Generate a regular grid with the desired spacing over the orientation
    % image.
    [rows,cols] = size(oim);
    [x,y] = meshgrid(1:spacing:cols, 1:spacing:rows);
    
    % Randomly dither the grid locations so that the grid pattern itself does
    % not interfere with your perception of the orientations.  This improves the
    % perception of the orientation pattern significantly.
    xr = round(x + spacing * rand(size(x))-0.5);
    yr = round(y + spacing * rand(size(y))-0.5);
    
    % Clamp dithered locations to image bounds.
    xr(xr < 1) = 1;    yr(yr < 1) = 1;
    xr(xr > cols) = cols;    yr(yr > rows) = rows;
    
    % Uncomment this if you want to see an undithered grid pattern
    % xr = x; yr = y;
    
    % Get orientation vectors at dithered grid locations
    ind = sub2ind(size(oim), yr, xr);
    u = reshape(mag(ind).*cos(oim(ind)), size(xr));
    v = reshape(mag(ind).*sin(oim(ind)), size(yr));

    if holdon, hold on; end
    
    h = quiver(xr,yr, u, v, linelen/2, 'color',[0 0 1]); 
    set(h, 'ShowArrowHead', 'off');
    hold on
    h = quiver(xr,yr,-u,-v, linelen/2, 'color',[0 0 1]); 
    set(h, 'ShowArrowHead', 'off');
    hold off
    axis off;  axis equal; axis tight; axis ij
    
    if holdon, hold off; end
    
%-------------------------------------------------------------------------
% Parse the input arguments and set defaults as necessary

function [oim, mag, spacing, fig, linelen, holdon]  = parseInputs(varargin)
    
    p = inputParser;
    numericORlogical = @(x) isnumeric(x) || islogical(x);
    
    % Required arguments
    addRequired(p, 'oim', @isnumeric);

    % Optional parameter-value pairs and their defaults    
    addParameter(p, 'mag', [], @isnumeric);
    addParameter(p, 'spacing', 5, @isnumeric);
    addParameter(p, 'fig', [], @isnumeric);        
    addParameter(p, 'linelen', 0.5, @isnumeric);
    addParameter(p, 'holdon', false, numericORlogical);
    
    parse(p, varargin{:});

    oim = p.Results.oim;
    mag = p.Results.mag;
    spacing = p.Results.spacing;
    fig = p.Results.fig;
    linelen = p.Results.linelen;
    holdon = p.Results.holdon;

    if isempty(mag) 
        mag = ones(size(oim));
    end    