% RAY2RAYDIST   Minimum distance between two 3D rays
%
% Usage: d = ray2raydist(p1, v1, p2, v2)
%
% Arguments:
%       p1, p2 - 3D points that lie on rays 1 and 2.
%       v1, v2 - 3D vectors defining the direction of each ray.
%
% Returns:
%            d - The minimum distance between the rays.
%
% Each ray is defined by a point on the ray and a vector giving the direction
% of the ray.  Thus a point on ray 1 will be given by  p1 + alpha*v1  where
% alpha is some scalar.

% Peter Kovesi
% peterkovesi.com
% June 2016

function d = ray2raydist(p1, v1, p2, v2)
    
    % Get vector perpendicular to both rays
    n = cross(v1, v2); n = n(:);
    nnorm = sqrt(n'*n);

    % Check if lines are parallel. If so, form a vector perpendicular to v1
    % that is within the plane formed by the parallel rays.
    if nnorm < eps; 
        n = cross(v1, p1-p2); % Vector perpendicular to plane formed by pair
                              % of rays.
        n = cross(v1, n);     % Vector perpendicular to v1 within the plane
        n = n(:);             % formed by the 2 rays.
        nnorm = sqrt(n'*n);

        if nnorm < eps
            d = 0;
            return
        end
    end                     
    
    n = n/nnorm;        % Unit vector
    
    % The vector joining the two closest points on the rays is:
    %    d*n = p2 + beta*v2 - (p1 + alpha*v1) 
    % for some unknown values of alpha and beta.   
    %
    % Take dot product of n on both sides
    %    d*n.n = p2.n + beta*v2.n - p1.n - alpha*v1.n
    %
    % as n is prependicular to v1 and v2 this reduces to
    %   d = (p2 - p1).n
    d = abs((p2(:)' - p1(:)')*n);

