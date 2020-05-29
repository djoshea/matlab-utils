% HIGHPASSMONOGENIC Compute phase and amplitude on highpass images via monogenic filters
%
% Usage: [phase, orient, E, f, h1f, h2f] = ...
%                highpassmonogenic(im, maxwavelength, n, useperiodicfft);
%
% Arguments:            im - Image to be processed.
%            maxwavelength - Wavelength(s) in pixels of the  cut-in frequency(ies)
%                            of the Butterworth highpass filter. 
%                        n - The order of the Butterworth filter. This is an
%                            integer >= 1.  The higher the value the sharper
%                            the cutoff.  I generaly do not use a value
%                            higher than 2 to avoid ringing artifacts.
%           useperiodicfft - Optional Boolean flag indicating whether the
%                            periodic fft should be used to apply the
%                            monogenic filters.  This can be very useful for
%                            eliminating edge artifacts.  The default value
%                            is false. 
%
% Returns:           phase - The local phase. Values are between -pi/2 and pi/2
%                   orient - The local orientation. Values between -pi and pi.
%                            Note that where the local phase is close to
%                            +-pi/2 the orientation will be poorly defined.
%                        E - Local energy, or amplitude, of the signal.
%                        f
%                      h1f
%                      h2f
%
% Note that maxwavelength can be an array in which case the outputs will all be
% cell arrays with an element for each corresponding maxwavelength value.
%
% See also: BANDPASSMONOGENIC, PERFFT2, MONOFILT

% Copyright (c) 2012-2018 Peter Kovesi
% www.peterkovesi.com
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
% March 2012
% Sept  2017 Changed to use FILTERGRID
% Nov   2018 Add option to use periodic fft

function [phase, orient, E, f, h1f, h2f] = highpassmonogenic(im, maxwavelength, ...
                                                      n, useperiodicfft)
    
    if ~exist('useperiodicfft', 'var'), useperiodicfft = false; end
    if ndims(im) == 3, im = rgb2gray(im); end
    assert(min(maxwavelength) >= 2, 'Minimum wavelength is 2 pixels')
    
    [rows,cols] = size(im);

    % We have the option of using the periodic fourier transform to minimise
    % edge effects. In general I find this useful but there is is issue of
    % whether one should add the smooth component of the decomposition back in
    % after the filtering.  Since we are performing high-pass filtering and
    % the smooth component should only have low frequencies this is probably
    % not an issue.
    if useperiodicfft
        IM = perfft2(double(im));
    else
        IM = fft2(double(im));        
    end

    % Generate horizontal and vertical frequency grids
    [radius, u1, u2] = filtergrid(rows,cols);
    
    % Get rid of the 0 radius value in the middle (at top left corner after
    % fftshifting) so that dividing by the radius, will not cause trouble.
    radius(1,1) = 1;
    
    H1 = i*u1./radius;   % The two monogenic filters in the frequency domain
    H2 = i*u2./radius;
    H1(1,1) = 0;
    H2(1,1) = 0;
    radius(1,1) = 0;  % undo fudge
    clear('u1', 'u2');
    
    if length(maxwavelength) == 1  % Only one scale requested
        % High pass Butterworth filter
        H =  1.0 - 1.0 ./ (1.0 + (radius * maxwavelength).^(2*n));        
        IM = IM.*H; 
        
        f = real(ifft2(IM));
        h1f = real(ifft2(H1.*IM));  clear('H1');
        h2f = real(ifft2(H2.*IM));  clear('H2', 'IM');
        
        phase = atan(f./sqrt(h1f.^2+h2f.^2 + eps));
        orient = atan2(h2f, h1f);
        E = sqrt(f.^2 + h1f.^2 + h2f.^2);    
        
    else  % Return output as cell arrays, with elements for each scale requested
        for s = 1:length(maxwavelength)
            % High pass Butterworth filter
            H =  1.0 - 1.0 ./ (1.0 + (radius * maxwavelength(s)).^(2*n)); 
            
            f{s} = real(ifft2(H.*IM));
            h1f{s} = real(ifft2(H.*H1.*IM));
            h2f{s} = real(ifft2(H.*H2.*IM));
            
            phase{s} = atan(f{s}./sqrt(h1f{s}.^2+h2f{s}.^2 + eps));
            orient{s} = atan2(h2f{s}, h1f{s});
            E{s} = sqrt(f{s}.^2 + h1f{s}.^2 + h2f{s}.^2);    
        end
    end
    
