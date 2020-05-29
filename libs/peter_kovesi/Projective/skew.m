% SKEW - Constructs 3x3 skew-symmetric matrix from 3-vector
%
% Usage:  s = skew(v)
%
% Argument:  v - 3-vector
% Returns:   s - 3x3 skew-symmetric matrix
%
% The cross product between two vectors, a x b can be implemented as a matrix
% product  skew(a)*b

% Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% peter.kovesi at uwa edu au

% October 2013

function s = skew(v)
    
    assert(numel(v) == 3);
    
    s = [ 0   -v(3)  v(2)
         v(3)   0   -v(1)
        -v(2)  v(1)   0 ];