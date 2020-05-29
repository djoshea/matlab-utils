% PLOTFRAME - plots a coordinate frame specified by a homogeneous transform 
%
% Usage: function plotframe(T, len, label, colr)
%
% Arguments:
%    T     - 4x4 homogeneous transform or 3x3 rotation matrix
%    len   - length of axis arms to plot (defaults to 1)
%    label - text string to append to x,y,z labels on axes
%    colr  - Three element array spcifying colour to plot axes.
%
%  len, label and colr are optional and default to 1 and '' and [0 0 1]
%  respectively.
%
% See also: ROTX, ROTY, ROTZ, TRANS, INVHT

% Peter Kovesi
% peterkovesi.com
% 2001       - Original version
% April 2016 - Allowance for 3x3 rotation matrices as as well as 4x4 homogeneous
%              transforms

function plotframe(T, len, label, colr)

    if all(size(T) == [3,3])  % we have a rotation matrix
        T = [ T      [0;0;0]
              0 0 0     1   ];
    end
    
    if ~all(size(T) == [4,4])
        error('plotframe: matrix is not 4x4')
    end
    
    if ~exist('len','var') || isempty(len)
        len = 1;
    end
    
    if ~exist('label','var') || isempty(label)
        label = '';
    end
    
    if ~exist('colr','var') || isempty(colr)
        colr = [0 0 1];
    end    
    
    % Assume scale specified by T(4,4) == 1
    
    origin = T(1:3, 4);             % 1st three elements of 4th column
    X = origin + len*T(1:3, 1);     % point 'len' units out along x axis
    Y = origin + len*T(1:3, 2);     % point 'len' units out along y axis
    Z = origin + len*T(1:3, 3);     % point 'len' units out along z axis
    
    line([origin(1),X(1)], [origin(2), X(2)], [origin(3), X(3)], 'color', colr);
    line([origin(1),Y(1)], [origin(2), Y(2)], [origin(3), Y(3)], 'color', colr);
    line([origin(1),Z(1)], [origin(2), Z(2)], [origin(3), Z(3)], 'color', colr);
    
    text(X(1), X(2), X(3), ['x' label], 'color', colr);
    text(Y(1), Y(2), Y(3), ['y' label], 'color', colr);
    text(Z(1), Z(2), Z(3), ['z' label], 'color', colr);
    
