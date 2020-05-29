% NEWANGLEAXIS - Constructs angle-axis descriptor
%
% Usage: t = newangleaxis(theta, axis)
%
% Arguments: theta - angle of rotation
%            axis  - 3-vector defining axis of rotation
% Returns:   t     - 3-vector giving rotation axis with magnitude equal to the
%                    rotation angle in radians.
%
% See also: MATRIX2ANGLEAXIS, ANGLEAXISROTATE, ANGLEAXIS2MATRIX
%           NORMALISEANGLEAXIS

% Copyright (c) 2008 Peter Kovesi
% peterkovesi.com

function t = newangleaxis(theta, axis)
    
    if length(axis) ~= 3
        error('axis must be a 3 vector');
    end
    
    axis = axis(:)/norm(axis(:));  % Ensure unit magnitude
    
    % Normalise theta to lie in the range -pi to pi to ensure one-to-one mapping
    % between angle-axis descriptor and resulting rotation. 
    theta = rem(theta, 2*pi);  % Remove multiples of 2pi
    
    if theta > pi
        theta = theta - 2*pi; 
    elseif  theta < -pi
        theta = theta + 2*pi; 
    end
    
    t = theta*axis;