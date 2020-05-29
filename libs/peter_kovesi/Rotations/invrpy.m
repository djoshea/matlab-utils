% INVRPY - inverse of Roll Pitch Yaw transform
%
% Usage:  [rpy1, rpy2] = invrpy(RPY)
% 
% Argument:  RPY - 4x4 Homogeneous transformation matrix or 3x3 rotation matrix
% Returns:  rpy1 = [phi1, theta1, psi1] - the 1st solution and
%           rpy2 = [phi2, theta2, psi2] - the 2nd solution
%
%    rotz(phi1)  * roty(theta1)  * rotx(psi1)    = RPY
%  rotz(rpy1(1)) * roty(rpy1(2)) * rotx(rpy1(3)) = RPY
%
%
% See also: INVEULER, INVHT, ROTX, ROTY, ROTZ

% Reference: Richard P. Paul  Robot Manipulators: Mathematics, Programming and Control.
% MIT Press 1981. Page 70
%
% Copyright (c) 2001 Peter Kovesi
% peterkovesi.com
%
% May 2015 Help documentation corrected!

function [rpy1, rpy2] = invrpy(RPY)

    % Z rotation 
    phi1 = atan2(RPY(2,1), RPY(1,1));  
    phi2 = phi1 + pi;
    
    % Y rotation
    theta1 = atan2(-RPY(3,1), cos(phi1)*RPY(1,1) + sin(phi1)*RPY(2,1));
    theta2 = atan2(-RPY(3,1), cos(phi2)*RPY(1,1) + sin(phi2)*RPY(2,1));
    
    % X rotation
    psi1 = atan2(sin(phi1)*RPY(1,3) - cos(phi1)*RPY(2,3), ...
                 -sin(phi1)*RPY(1,2) + cos(phi1)*RPY(2,2));
    psi2 = atan2(sin(phi2)*RPY(1,3) - cos(phi2)*RPY(2,3), ...
                 -sin(phi2)*RPY(1,2) + cos(phi2)*RPY(2,2));
    
    rpy1 = [phi1, theta1, psi1];
    rpy2 = [phi2, theta2, psi2];
    