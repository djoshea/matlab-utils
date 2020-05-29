% IMAGEPT2PLANE - Project image points to a plane and return their 3D locations
%
% Usage:  pt = imagept2plane(C, xy, planeP, planeN)
%
% Arguments:  
%          C - Camera structure, see CAMSTRUCT for definition.  Alternatively
%              C can be a 3x4 camera projection matrix.
%         xy - Image points specified as 2 x N array (x,y) / (col,row)
%     planeP - Some point on the plane.
%     planeN - Plane normal vector.
%
% Returns:
%         pt - 3xN array of 3D points on the plane that the image points
%              correspond to. 
%
% Note that the plane is specified in terms of the world frame by defining a
% 3D point on the plane, planeP, and a surface normal, planeN.
%
% Lens distortion is handled by using the standard lens distortion parameters,
% assuming locally that the distortion is constant, computing the forward
% distortion and then subtracting the distortion.
% 
% See also CAMSTRUCT, CAMERAPROJECT

% Copyright (c) 2015-2016 Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% peter.kovesi at uwa edu au
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

% May 2015 - Original version
% Jan 2016 - Removed use of inverse lens distortion parameters and instead
%            use the standard lens distortion parameters, assuming locally
%            that the distortion is constant, and subtracting the distortion.

function pt = imagept2plane(C, xy, planeP, planeN)
    
    [dim,N] = size(xy);
    if dim ~= 2
        error('Image xy data must be a 2 x N array');
    end
    
    if ~isstruct(C) && all(size(C) == [3,4])  % We have a projection matrix
        C = projmatrix2camstruct(C);          % Convert to camera structure
    end
        
    planeP = planeP(:);    % Ensure column vectors
    planeN = planeN(:);
    
    % Reverse the projection process as used by CAMERAPROJECT

    % If only one focal length specified in structure use it for both fx and fy
    if isfield(C, 'f')
        fx = C.f;
        fy = C.f;
    elseif isfield(C, 'fx') && isfield(C, 'fy')
        fx = C.fx;
        fy = C.fy;        
    else
        error('Invalid focal length specification in camera structure');
    end    

    if isfield(C, 'skew')     % Handle optional skew specfication
        skew = C.skew;
    else
        skew = 0;
    end    
    
    % Subtract principal point and divide by focal length to get normalised,
    % distorted image coordinates.  Note skew represents the 2D shearing
    % coefficient times fx
    y_d = (xy(2,:) - C.ppy)/fy;   
    x_d = (xy(1,:) - C.ppx - y_d*skew)/fx;   

    % Radial distortion factor.  Here the squared radius is computed from the
    % already distorted coordinates.  The approximation we are making here is to
    % assume that the distortion is locally constant.
    rsqrd = x_d.^2 + y_d.^2;
    r_d = 1 + C.k1*rsqrd + C.k2*rsqrd.^2 + C.k3*rsqrd.^3;
    
    % Tangential distortion component, again computed from the already distorted
    % coords.
    dtx = 2*C.p1*x_d.*y_d         + C.p2*(rsqrd + 2*x_d.^2);
    dty = C.p1*(rsqrd + 2*y_d.^2) + 2*C.p2*x_d.*y_d;    
    
    % Subtract the tangential distortion components and divide by the radial
    % distortion factor to get an approximation of the undistorted normalised
    % image coordinates (with no skew)
    x_n = (x_d - dtx)./r_d;
    y_n = (y_d - dty)./r_d;

    % Define a set of points at the normalised distance of z = 1 from the
    % principal point, these define the viewing rays in terms of the camera
    % frame.
    ray = [x_n; y_n; ones(1,N)];  
                          
    % Rotate to get the viewing rays in the world frame
    ray = C.Rc_w'*ray;      
    
    % The point of intersection of each ray with the plane will be 
    %   pt = C.P + k*ray    where k is to be determined
    %
    % Noting that the vector planeP -> pt will be perpendicular to planeN.
    % Hence the dot product between these two vectors will be 0.  
    %  dot((( C.P + k*ray ) - planeP) , planeN)  = 0
    % Rearranging this equation allows k to be solved
    pt = zeros(3,N);
    for n = 1:N
%        k = (dot(planeP, planeN) - dot(C.P, planeN)) / dot(ray(:,n), planeN);
        k = (planeP'*planeN - C.P'*planeN) / (ray(:,n)'*planeN);       % Much faster!
        
        pt(:,n) = C.P + k*ray(:,n);
    end