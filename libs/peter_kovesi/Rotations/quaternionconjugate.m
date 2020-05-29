% QUATERNIONCONJUGATE - Conjugate of a quaternion
%
% Usage: Qconj = quaternionconjugate(Q)
%
% Argument: Q     - Quaternions in the form  Q = [Qw Qi Qj Qk]
% Returns:  Qconj - Conjugate
%
% See also: NEWQUATERNION, QUATERNIONROTATE, QUATERNIONPRODUCT

% Copyright (c) 2008 Peter Kovesi
% peterkovesi.com

function Qconj = quaternionconjugate(Q)
    
    Qconj = Q(:);
    Qconj(2:4) = -Qconj(2:4);
