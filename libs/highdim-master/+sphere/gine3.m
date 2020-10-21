% GINE3                       Gine test for spherical uniformity (p=3)
% 
%     [pval,Fn] = gine3(U)
%
%     INPUTS
%     U - [n x 3] matrix, n samples with dimensionality 3
%         the data should already be projected to the unit hypersphere
%
%     OUTPUTS
%     pval - p-value
%     Fn - statistic
%
%     REFERENCE
%     Mardia, KV, Jupp, PE (2000). Directional Statistics. John Wiley
%
%     SEE ALSO
%     UniSphereTest, spatialSign

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

function [pval,Fn] = gine3(U)

[n,p] = size(U);

if p ~= 3
   error('Only valid for p = 3');
end

psi = sphere.psivec(U,n);
% eq. 10.4.8
Fn = (3*n)/2 - (4/(n*pi)) * sum(psi + sin(psi));

pval = 1 - sphere.sumchi2cdf(Fn,3);
