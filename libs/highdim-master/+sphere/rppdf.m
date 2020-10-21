% RPPDF                       Distribution of angles on a uniform hypersphere
% 
%     h = rppdf(theta,p)
%
%     The distribution of pairwise angles between vectors X1,...,Xn that 
%     are random points independently chosen with the uniform distribution 
%     on S^(p-1), the unit sphere in R^p.
%
%     INPUTS
%     theta - angles (radians) to evaluate pdf
%     p     - dimensionality (R^p)
%
%     OUTPUTS
%     h     - pdf
%
%     EXAMPLE
%     p = 8;
%     x = randn(50000,p);
%     U = sphere.spatialSign(x);
%     u0 = sphere.spatialSign(randn(1,p));
%     dx = 0.05; xx = 0:dx:pi;
%     n = histc(acos(U*u0'),xx);
%     hold on
%     bar(xx,n./sum(n),'histc');
%     plot(xx,sphere.rppdf(xx,p)*dx,'m')
% 
%     integral(@(x) sphere.rppdf(x,p),0,pi)
%
%     REFERENCE
%     Cai, T et al (2013). Distribution of angles in random packing on
%       spheres. J of Machine Learning Research 14: 1837-1864.
%
%     SEE ALSO
%     rp, rpcdf

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

function h = rppdf(theta,p)

assert(all(theta>=0)&&all(theta<=pi),'theta must be 0<=theta<=pi.');
assert((mod(p,1)==0)&&(p>1),'p must be integer > 0.');

h = (1/sqrt(pi)) * exp( gammaln(p/2) - gammaln((p-1)/2) )*...
    (sin(theta).^(p-2));
