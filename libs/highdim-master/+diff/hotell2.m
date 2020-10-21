% HOTELL2                     Hotelling's T-Squared test for two multivariate samples 
% 
%     [pval,T2] = hotell2(x,y)
%
%     Hotelling's T-Squared test for comparing d-dimensional data from two 
%     independent samples, assuming normality w/ common covariance matrix.
%
%     INPUTS
%     x    - [n1 x d] matrix
%     y    - [n2 x d] matrix
%
%     OUTPUTS
%     pval - asymptotic p-value
%     T2   - Hotelling T^2 statistic
%
%     REFERENCE
%     Mardia, K, Kent, J, Bibby J (1979) Multivariate Analysis. Section 3.6.1
%
%     SEE ALSO
%     kstest2d, minentest

%     $ Copyright (C) 2014 Brian Lau http://www.subcortex.net/ $
%     The full license and most recent version of the code can be found on GitHub:
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

function [pval,T2] = hotell2(x,y)

[nx,px] = size(x);
[ny,py] = size(y);

if px ~= py
   error('# of columns in X and Y must match');
else
   p = px;
end

n = nx + ny;
mux = mean(x);
muy = mean(y);

Sx = cov(x);
Sy = cov(y);

% Hotelling T2 statistic, Section 3.6.1 Mardia et al.
%Su = ((nx-1)*Sx + (ny-1)*Sy) / (n-2);
Su = (nx*Sx + ny*Sy) / (n-2); % unbiased estimate
d = mux - muy;
D2 = d*inv(Su)*d';
T2 = ((nx*ny)/n)*D2;
F = T2 * (n-p-1) / ((n-2)*p);

pval = 1 - fcdf(F,p,n-p-1);

if nargout == 0
   fprintf('-------------------------------\n');
   fprintf('  nx = %g\n',nx);
   fprintf('  ny = %g\n',ny);
   fprintf('  mean(x) = ');
   fprintf('%1.3f, ',mux);
   fprintf('\n');
   fprintf('  mean(y) = ');
   fprintf('%1.3f, ',muy);
   fprintf('\n');
   fprintf('  T2 = %5.3f\n',T2);
   fprintf('  F(%g,%g) = %5.3f\n',p,n-p-1,F);
   fprintf('  p = %5.5f\n',pval);
   fprintf('-------------------------------\n');
end