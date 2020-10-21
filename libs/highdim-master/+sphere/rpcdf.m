% RPCDF                       CDF of angles on a uniform hypersphere
% 
%     c = rpcdf(theta,p,dx)
%
%     INPUTS
%     theta - angles (radians) to evaluate pdf
%     p     - dimensionality (R^p)
%
%     OPTIONAL
%     dx    - resolution (default = 0.001);
%
%     OUTPUTS
%     h     - cdf
%
%     REFERENCE
%     Cai, T et al (2013). Distribution of angles in random packing on
%     spheres. J of Machine Learning Research 14: 1837-1864.
%
%     SEE ALSO
%     rppdf, rp

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

function c = rpcdf(theta,p,dx)

if nargin < 3
   dx = 0.001;
end

x = 0:dx:pi;
h = sphere.rppdf(x,p);

c = cumtrapz(x,h);
c = interp1(x,c,theta);