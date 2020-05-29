% NORMALISEANGLEAXIS - normalises angle-axis descriptor
%
% Function normalises theta so that it lies in the range -pi to pi to ensure
% one-to-one mapping between angle-axis descriptor and resulting rotation
%
% Usage: t2 = normaliseangleaxis(t)
%
% Argument:   t  - 3-vector giving rotation axis with magnitude equal to the
%                  rotation angle in radians.
% Returns:    t2 - Normalised angle-axis descriptor
%
% See also: MATRIX2ANGLEAXIS, NEWANGLEAXIS, ANGLEAXIS2MATRIX, ANGLEAXIS2MATRIX2,
%           ANGLEAXISROTATE

% Copyright (c) 2008 Peter Kovesi
% peterkovesi.com

function t2 = normaliseangleaxis(t)
    
    if length(t) ~= 3
        error('axis must be a 3 vector');
    end
    
    theta = norm(t);
    axis = t/theta;
    
    theta = rem(theta, 2*pi);  % Remove multiples of 2pi
    
    if theta > pi              % Note theta cannot be -ve
        theta = theta - 2*pi; 
    end
    
    t = theta*axis;
    
    if norm(t) > pi
        t2 = t*(1 - (2*pi)/norm(t));
    else
        t2 = t;
    end
    
