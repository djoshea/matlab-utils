% JBLD                        Jensen-Bregman LogDet Divergence
% 
%     div = jbld(x,y)
%
%     INPUTS
%     x - [n x n] positive semi-definite matrix
%     y - [n x n] positive semi-definite matrix
%
%     OUTPUTS
%     div - Jensen-Bregman LogDet Divergence
%
%     REFERENCE
%     Cherian et al (2012). Jensen-Bregman LogDet Divergence with Application 
%       to Efficient Similarity Search for Covariance Matrices. 
%       Trans Pattern Analysis & Machine Intelligence 

%     $ Copyright (C) 2014 Brian Lau http://www.subcortex.net/ $
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

function div = jbld(x,y)

[m,p] = size(x);
[n,q] = size(y);

if (m~=n) || (p~=q)
   error('x and y must be the same size');
end

cxy = chol((x+y)/2);
cx = chol(x);
cy = chol(y);
div = log(prod(diag(cxy).^2)) - log(prod(diag(cx).^2)*prod(diag(cy).^2))/2;

% div2 = log(det((x+y)/2)) - log(det(x*y))/2;