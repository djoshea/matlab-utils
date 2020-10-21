% DCENTER                     Double-center distance matrix
% 
%     [X,X_j,X__] = dcenter(X)
%
%     Double-centers distance matrix X:
%     
%        X_{ij} - X_{i.}/n - X_{.j}/n + X_{..}/n^2, all i, j
%
%     Faster & more memory-efficient than using a centering matrix
%        H = eye(n) - ones(n)/n; X = H*X*H;
%
%     INPUTS
%     X - [n x n] symmetric distance matrix
%
%     OUTPUTS
%     X   - centered distance matrix
%     X_j - column means of X (input)
%     X__ - mean of X (input)
%
%     SEE ALSO
%     ucenter

%     $ Copyright (C) 2017 Brian Lau, brian.lau@upmc.fr $
%     The full license and most recent version of the code can be found at:
%     https://github.com/brian-lau/highdim
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.

function [X,X_j,X__] = dcenter(X)

[n,m] = size(X);
assert(m==n,'DCENTER operates on square, symmetric distance matrices');

X_j = mean(X);
X__ = mean(X_j); % mean(X(:))
X = X - bsxfun(@plus,X_j,X_j') + X__;