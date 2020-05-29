% ROTX - Homogeneous transformation for a rotation about the x axis
%
% Usage: T = rotx(theta)
%
% Argument:  theta  - rotation about x axis
% Returns:    T     - 4x4 homogeneous transformation matrix
%
% See also: TRANS, ROTY, ROTZ, INVHT

% Peter Kovesi 2001
% peterkovesi.com

function T = rotx(theta)

T = [ 1     0           0        0
      0  cos(theta) -sin(theta)  0
      0  sin(theta)  cos(theta)  0
      0     0           0        1];

