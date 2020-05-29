% HOMOGRAPHY1D - computes 1D homography
%
% Usage:   H = homography1d(x1, x2)
%
% Arguments:
%          x1  - 2xN set of homogeneous points
%          x2  - 2xN set of homogeneous points such that x1<->x2
% Returns:
%          H - the 2x2 homography such that x2 = H*x1
%
% This code is modelled after the normalised direct linear transformation
% algorithm for the 2D homography given by Hartley and Zisserman p92.
%

% Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% peter.kovesi at uwa edu au
%
% May   2003
% March 2018 Fix to normalise1dpts (thanks to Daniel DeMenthon)

function H = homography1d(x1, x2)

  % check matrix sizes
  if ~all(size(x1) == size(x2))
    error('x1 and x2 must have same dimensions');
  end
  
  % Attempt to normalise each set of points so that the origin 
  % is at centroid and mean distance from origin is 1.
  [x1, T1] = normalise1dpts(x1);
  [x2, T2] = normalise1dpts(x2);

  % Note that it may have not been possible to normalise
  % the points if one was at infinity so the following does not
  % assume that scale parameter w = 1.
  Npts = length(x1);
  A = zeros(2*Npts,4);

  for n = 1:Npts
    X = x1(:,n)';
    x = x2(1,n);  w = x2(2,n);
    A(n,:) = [-w*X x*X];
  end

  [U,D,V] = svd(A);

  % Extract homography
  H = reshape(V(:,4),2,2)';

  % Denormalise
  H = T2\H*T1;

  % Report error in fitting homography...

% NORMALISE1DPTS - normalises 1D homogeneous points
%
% Function translates and normalises a set of 1D homogeneous points 
% so that their centroid is at the origin and their mean distance from 
% the origin is 1.  
%
% Usage:   [newpts, T] = normalise1dpts(pts)
%
% Argument:
%   pts -  2xN array of 2D homogeneous coordinates
%
% Returns:
%   newpts -  2xN array of transformed 1D homogeneous coordinates
%   T      -  The 2x2 transformation matrix, newpts = T*pts
%           
% If there are some points at infinity the normalisation transform
% is calculated using just the finite points.  Being a scaling and
% translating transform this will not affect the points at infinity.

function [newpts, T] = normalise1dpts(pts)

    % Find the indices of the points that are not at infinity
    finiteind = find(abs(pts(2,:)) > eps);

    % Ensure homogeneous coords have scale of 1
    pts(1,finiteind) = pts(1,finiteind)./pts(2,finiteind);
    pts(2,finiteind) = 1;
    
    c = mean(pts(1,finiteind)');       % Centroid.
    newp = pts(1,finiteind)-c;         % Shift origin to centroid.
    
    meandist = mean(abs(newp));
    scale = 1/meandist;
    
    T = [scale    -scale*c
         0         1      ];
    
    newpts = T*pts;

