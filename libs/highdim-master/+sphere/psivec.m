% PSIVEC                      Vector pairwise angles, i < j
% 
%     psi = psivec(U,n)
%
%     INPUTS
%     U - [n x p] matrix, n samples with dimensionality p
%         the data should already be projected to the unit hypersphere
%     n - number of samples
%
%     OUTPUTS
%     psi - vector from psi matrix (U*U'), i < j
%
%     REFERENCE
%     Mardia, KV, Jupp, PE (2000). Directional Statistics. John Wiley   
%
%     SEE ALSO
%     gine, gine3, ajne, gineajne

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

function psi = psivec(U,n)

xx = triu(U*U',1);
ind = triu(ones(n,n),1);
psi = acos(xx(ind==1));
