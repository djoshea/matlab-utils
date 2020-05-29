% ROTY - Homogeneous transformation for a rotation about the y axis
%
% Usage: T = roty(theta)
%
% Argument:  theta  - rotation about y axis
% Returns:    T     - 4x4 homogeneous transformation matrix
%
% See also: TRANS, ROTX, ROTZ, INVHT

% Peter Kovesi 2001
% peterkovesi.com

function T = roty(theta)

T = [ cos(theta)  0  sin(theta)  0
          0       1      0       0
     -sin(theta)  0  cos(theta)  0
          0       0      0       1];

