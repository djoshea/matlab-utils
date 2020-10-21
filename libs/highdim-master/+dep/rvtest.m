% RVTEST                      Test RV coefficient of dependence
% 
%     [pval,rv,stat] = rvtest(x,y)
%
%     INPUTS
%     x - [n x p] n samples of dimensionality p
%     y - [n x q] n samples of dimensionality q
%
%     OUTPUTS
%     pval - p-value from Pearson type III approximation
%     rv   - RV coefficient
%     stat - test statistic, normalized RV coefficient
%
%     REFERENCE
%     Josse et al (2008). Testing the significance of the RV coefficient.
%       Computational Statistics and Data Analysis 53: 82-91
%
%     SEE ALSO
%     rv, dcorr, dcorrtest, DepTest2

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

function [pval,rv,stat] = rvtest(x,y)

[n,~] = size(x);
assert(n == size(y,1),'RVTEST requires x and y to have the same # of samples');

[rv,xx,yy] = dep.rv(x,y);
      
% mean
bx = trace(xx)^2/trace(xx^2);
by = trace(yy)^2/trace(yy^2);
mu_rv = sqrt(bx*by)/(n-1);

% variance
tx = (n-1)/((n-3)*(n-1-bx)) * ...
     (n*(n+1)*(sum(diag(xx).^2)/trace(xx^2)) - (n-1)*(bx+2));
ty = (n-1)/((n-3)*(n-1-by)) * ...
     (n*(n+1)*(sum(diag(yy).^2)/trace(yy^2)) - (n-1)*(by+2));
var_rv = (2*(n-1-bx)*(n-1-by))/((n+1)*(n-1)^2*(n-2)) *...
     (1 + ((n-3)/(2*n*(n-1)))*tx*ty);

% Standardized RV coefficient
stat = (rv - mu_rv)/sqrt(var_rv);

% Skewness estimate for Pearson III approximation
[~,~,skew] = utils.permMoments(xx,yy);

if skew >= 0
   pval = gamcdf(stat - (-2/skew),4/skew^2,skew/2,'upper');
else
   as = abs(skew);
   pval = gamcdf(skew/as*stat + 2/as,4/skew^2,as/2);
end

end