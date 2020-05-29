% POINTINCONVEXPOLY Determine if a 2D point is within a convex polygon
%
% Usage:  v = pointinconvexpoly(p, poly)
%
% Arguments:   p - 2D point.
%           poly - Convex polygon defined as a series of vertices in
%                  sequence, clockwise or anticlockwise around the polygon as
%                  a 2 x N array.
%
% Returns:    v - +1 if within the polygon
%                 -1 if outside
%                  0 if on the boundary
%
% Warning:  There is no check to see if the polygon is indeed convex.

% Strategy: Determine whether, in traveling from p to a vertex and then to the
% following vertex, we turn clockwise or anticlockwise.  If for every vertex we
% turn consistently clockwise, or consistently anticlockwise we are inside the
% polygon.  If for one of the vertices we did not turn clockwise or
% anticlockwise then we must be on the boundary.

% Peter Kovesi
% pk@peterkovesi.com
% May 2015

function v = pointinconvexpoly(p, poly)
    
    [dim, N] = size(poly);
    
    if length(p) ~= 2 || dim ~= 2
        error('Data must be 2D');
    end
    
    % Append a copy of the first vertex to the end for convenience
    poly = [poly poly(:,1)];  % We now have N+1 vertices
    
    % Determine whether, in traveling from p to a vertex and then to the
    % following vertex, we turn clockwise or anticlockwise
    c = zeros(N,1);
    for n = 1:N
        c(n) = clockwise(p, poly(:,n), poly(:,n+1));
    end
    
    % If for every vertex we turn consistently clockwise, or consistently
    % anticlockwise we are inside the polygon.  If for one of the vertices we
    % did not turn clockwise or anticlockwise then we must be on the
    % boundary. 
    if all(c >= 0) || all(c <= 0)
        if any(c==0)  % We are on the boundary
            v = 0;
        else          % We are inside
            v = 1;
        end
    else              % We are outside
        v = -1;
    end
    
%----------------------------------------------------------------------
% Determine whether, in traveling from p1 to p2 to p3 we turn clockwise or
% anticlockwise.  Returns +1 for clockwise, -1 for anticlockwise, and 0 for
% p1, p2, p3 in a straight line.
    
function v = clockwise(p1, p2, p3)
    
    % Form vectors p1->p2 and p2->p3 with z component = 0, form cross product
    % if the resulting z value is -ve the vectors turn clockwise, if +ve
    % anticlockwise, and if 0 the points are in a line.
        
    v = -sign((p2(1)-p1(1))*(p3(2)-p2(2)) - (p2(2)-p1(2))*(p3(1)-p2(1)));        
