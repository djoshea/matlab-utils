% SPATIALSIGN                 Project data onto unit hypersphere
% 
%     U = spatialSign(x)
%
%     INPUTS
%     x - [n x p] matrix, p being data-dimensionality
%
%     OUTPUTS
%     U - [n x p] matrix, each row normalized to unit length

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

function U = spatialSign(x)

U = bsxfun(@rdivide,x,sqrt(sum(x.^2,2)));
U(isnan(U)) = 0;