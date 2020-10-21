function R = rotation_angle_axis(theta,u)
%ROTATION_ANGLE_AXIS The Rodrigues' formula for rotation matrices.
%   R = ROTATION_ANGLE_AXIS(THETA,U) 
%
%  The formula recieves an angle of rotation given by theta and a unit vector, 
%  u, that defines the axis of rotation.
% 
%       ARGUMENT DESCRIPTION:
%           THETA - angle of rotation (radians).
%               U - unit vector
% 
%       OUTPUT DESCRIPTION:
%               R - rotation matrix.
% 
%   Example
%   -------------
%   R = rotation_angle_axis(deg2rad(pi/6),[sqrt(2)/2, 0.0, sqrt(2)/2])
% 

% Credits:
% Daniel Simoes Lopes
% IDMEC
% Instituto Superior Tecnico - Universidade Tecnica de Lisboa
% danlopes (at) dem ist utl pt
% http://web.ist.utl.pt/daniel.s.lopes/
%
% July 2011 original version.


%__________________________________________________________________________
%  Rodrigues' rotation formula.
u = u./norm(u,2);
S = [    0  u(3) -u(2);
      -u(3)   0   u(1);
       u(2) -u(1)   0  ];
R = eye(3) + sin(theta)*S + (1-cos(theta))*S^2;