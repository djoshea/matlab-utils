% BINGHAM                     Bingham test for spherical uniformity 
% 
%     [pval,B] = bingham(U)
%
%     Antipodially symmetric
%     Not consistent against alternatives with E[xx'] = (1/p)*Ip
%
%     INPUTS
%     U - [n x p] matrix, n samples with dimensionality p
%         the data should already be projected to the unit hypersphere
%
%     OUTPUTS
%     pval - p-value
%     B - statistic
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

function [pval,B] = bingham(U)

[n,p] = size(U);

if 1
   % eq. 10.7.1
   T = (1/n)*U'*U;
   B = ((n*p*(p+2))/2)*(trace(T^2) - 1/p);
else
   % Modified Bingham test statistic (Mardia & Jupp, eq. 10.7.3)
   % seems to blow up for certain data?
   T = (1/n)*U'*U;
   B = ((n*p*(p+2))/2)*(trace(T^2) - 1/p);
   B0 = (2*p^2+3*p+4)/(6*(p+4));
   B1 = -(4*p^2+3*p-4)/(3*(p+4)*(p^2+p+2));
   B2 = 4*(p^2-4)/(3*(p+4)*(p^2+p+2)*(p^2+p+6));
   B = B*(1 - (1/n)*(B0 + B1*B + B2*B^2));
end

pval = 1 - chi2cdf(B,((p-1)*(p+2))/2);
