% ROTZ - Homogeneous transformation for a rotation about the z axis
%
% Usage: T = rotz(theta)
%
% Argument:  theta  - rotation about z axis
% Returns:    T     - 4x4 homogeneous transformation matrix
%
% See also: TRANS, ROTX, ROTY, INVHT

% Peter Kovesi 2001
% peterkovesi.com

function T = rotz(theta)

T = [ cos(theta) -sin(theta)  0   0
      sin(theta)  cos(theta)  0   0
          0           0       1   0
          0           0       0   1];

