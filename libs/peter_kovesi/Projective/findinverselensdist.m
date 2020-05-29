% FINDINVERSELENSDIST - Find inverse radial lens distortion parameters
% 
% Usage: [ik1, ik2, maxerr] = findinverselensdist(k1, k2, rmax, fig)
%
% Arguments:   k1, k2 - Radial lens distortion coeffecients.
%                rmax - Maximum normalised radius to consider in fitting the
%                       inverse lens distortion function.  If omitted this
%                       parameter defaults to 0.43 which roughly corresponds
%                       to the normalized distance to the corner of a 35mm
%                       sensor with a 50mm lens.  Use smaller values for
%                       longer lenses as this will improve accuracy. 
%                       50mm  lens -> rmax ~0.43
%                       100mm lens -> rmax ~0.22
%                       200mm lens -> rmax ~0.11
%                 fig - Optional figure number to plot fitted result to.
%
% Returns:   ik1, ik2 - Radial lens distortion coefficients that attempt to
%                       invert the distortion.
%              maxerr - Maximum error between corrected radius and ideal
%                       radius reprted in normalised radius units.
%
% Given the distortion model as a function of radius from the principal point
%
%    rd = r*(1 + k1*r^2 + k2*r^4)
%
% where r is the undistorted normalised radius and rd is the distorted radius.
% Rather than try to solve for the inverse of this 5th order polynomial this
% function numerically fits a function of the same form, but with new
% coefficients for k1 and k2, that attempts to recover r from the distorted
% values in rd.
%
%    r = rd*(1 + ik1*rd^2 + ik2*rd^4)
%
% Thus r will not be exact, however the approximation is typically very good.
% The maximum error is reported back as maxerr.  The ratio of maxerr to rmax
% is probably what you should be concerned with.
%
% Note the normalised image radius corresponds to the radius on an image plane
% with a focal length of 1.
%
% See also: CAMERAPROJECT, IMAGEPT2PLANE

% Copyright (c) 2010 Peter Kovesi
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

% October 2010 

function [ik1, ik2, maxerr] = findinverselensdist(k1, k2, rmax, fig)
    
    % Set up the range of radius values to fit the inverse function to.  
    if ~exist('rmax', 'var'), rmax = 0.43; end        
    r = [0:rmax/100:rmax]';            
                                  
    d = 1.0 + k1*r.^2 + k2*r.^4;  % Distortion factor
    rd = r.*d;                    % Distorted radius
    
    % Least squares solution to the inverse transform    
    ik = [rd.^3  rd.^5]\(r-rd); 
    ik1 = ik(1);
    ik2 = ik(2);
    
    % Check results.  Correct the distorted radius values and see how close
    % the corrected values are to the ideal ones
    rc = rd.*(1.0 + ik1*rd.^2 + ik2*rd.^4);  % Corrected radius values

    maxerr = max(abs(r-rc));    
    
    if exist('fig', 'var')  % Produce diagnostic plots
        figure(fig), clf
        subplot(2,1,1)
        plot(r, r, r, rc, r, rd)
        title('Distorted vs corrected radius')
        xlabel('Normalised radius'); 
        legend('Ideal radius', 'Corrected radius', 'Distorted radius', ...
               'Location', 'NorthWest' )
        
        subplot(2,1,2)
        plot(r,(r-rc))
        title('Error between corrected radius and ideal radius')
        xlabel('Normalised radius'); 
    end
    
