% UCENTER                     U-center distance matrix
% 
%     [X,X_j,X__] = ucenter(X)
%
%     U-center distance matrix
%
%        X_{ij} - X_{i.}/(n-2) - X_{.j}/(n-2) + X_{..}/((n-1)(n-2)), i \neq j
%   
%     and zero diagonal
%
%     INPUTS
%     X - [n x n] symmetric distance matrix
%
%     OUTPUTS
%     X - centered distance matrix
%     X_j - column means of X (input)
%     X__ - mean of X (input)
%
%     SEE ALSO
%     pcenter

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

function [X,X_j,X__] = ucenter(X)

[n,m] = size(X);
assert(m==n,'UCENTER operates on square, symmetric distance matrices');

X_j = sum(X);
X__ = sum(X_j); % sum(X(:))
X = X - bsxfun(@plus,X_j,X_j')/(n-2) + X__/((n-1)*(n-2));
X(1:(n+1):n*n) = 0;
