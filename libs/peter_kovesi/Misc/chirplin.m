% CHIRPLIN   Generates linear chirp test image
%
% The test image consists of a linear chirp signal in the horizontal direction
% with the amplitude of the chirp being modulated from 1 at the top of the image
% to 0 at the bottom.
%
% Usage: im = chirplin(sze, w0, w1, p)
%
% Arguments:     sze - [rows cols] specifying size of test image.  If a
%                      single value is supplied the image is square.
%             w0, w1 - Initial and final wavelengths of the chirp pattern.
%                  p - Power to which the linear attenuation of amplitude, 
%                      from top to bottom, is raised.  For no attenuation use
%                      p = 0. For contrast sensitivity experiments use larger
%                      values of p.  The default value is 4.
%
% Example:  im = chirplin(500, 40, 2, 4)
%
% I have used this test image to evaluate the effectiveness of different
% colourmaps, and sections of colourmaps, over varying spatial frequencies and
% contrast.
%
% See also: CHIRPEXP, SINERAMP

% Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% peter.kovesi at uwa edu au
% 
% March    2012
% February 2015  Changed the arguments so that the chirp is specifeied in
%                terms of the initial and final wavelengths.

function im = chirplin(sze, w0, w1, p)
    
    if length(sze) == 1
        rows = sze; cols = sze;
    elseif length(sze) == 2
        rows = sze(1); cols = sze(2);
    else
        error('size must be a 1 or 2 element vector');
    end
    
    if ~exist('p', 'var'), p = 4; end
           
    if w1 > w0
        tmp = w1;
        w1 = w0;
        w0 = tmp;
        flip = 1;
    else
        flip = 0;
    end
    
    x = 0:cols-1;
    
    % Spatial frequency varies from f0 = 1/w0 to f1 = 1/w1 over the width of the
    % image following the expression f(x) = f0*(k*x+1)
    % We need to compute k given w0, w1 and width of the image.
    f0 = 1/w0;
    f1 = 1/w1;
    k = (f1/f0 - 1)/(cols-1);
    fx = sin(f0*(k.*x+1).*x);        
    
    A = ([(rows-1):-1:0]/(rows-1)).^p;
    
    if flip
        im = fliplr(A'*fx);
    else
        im = A'*fx;
    end