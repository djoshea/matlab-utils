% COVTEST                     Two-sample covariance matrix test
% 
%     [pval,stat,Mthresh] = covtest(x,y,varargin)
%
%     Given a sample X1,...,Xm from a p-dimensional multivariate distribution,
%     and a sample Y1,...,Xn from a q-dimensional multivariate distribution,
%     test one of the hypotheses:
%
%     H0 : cov(X) = cov(Y)
%
%     It is also possible to test the support of cov(x) ~= cov(y), which is
%     controlled at family-wise error rate = alpha.
%
%     INPUTS
%     x - [m x p] m samples of dimensionality p
%     y - [n x p] n samples of dimensionality p
%
%     OPTIONAL
%     alpha - level for test of support cov(x) ~= cov(y) (default = 0.05)
%
%     OUTPUTS
%     pval - p-value
%     stat - statistic
%     Mthresh - support cov(x) ~= cov(y), indicating significantly different
%           entries at level alpha
%
%     REFERENCE
%     Cai et al (2013). Two-sample covariance matrix testing and support
%       recovery in high-dimensional and sparse settings. Journal of the
%       American Statistical Association 108: 265-277

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

% TODO
%  o small sample (n<30) modification
%  x support test
%  o row test

function [pval,stat,Mthresh] = covtest(x,y,varargin)

par = inputParser;
par.KeepUnmatched = true;
addRequired(par,'x',@isnumeric);
addRequired(par,'y',@isnumeric);
addParamValue(par,'alpha',0.05,@(x) isscalar(x)&&isnumeric(x));
addParamValue(par,'row',[],@(x) isscalar(x)&&isnumeric(x));
parse(par,x,y,varargin{:});

[m,p] = size(x);
[n,q] = size(y);

if ne(p,q)
   error('Dimensions must match');
end

Sx = cov(x,1);
Sy = cov(y,1);
x_theta = normvar(x,p,m,Sx);
y_theta = normvar(y,p,n,Sy);
M = (Sx - Sy).^2 ./ (x_theta/m + y_theta/n); % eq 2
Mn = max(max(triu(M)));

stat = Mn - 4*log(p) + log(log(p));
cdf = @(y) exp(-exp(-y/2)/sqrt(8*pi));
pval = 1 - cdf(stat);

if nargout > 2
   % Support Sx-Sy
   Mthresh = M;
   q = -log(8*pi) - 2*log(log(1 - par.Results.alpha))^(-1);
   Mthresh = Mthresh >= (4*log(p) - log(log(p)) + q);
   Mthresh = utils.putdiag(Mthresh,diag(M) >= 2*log(p));
end

function theta = normvar(x,p,n,S)
mu = mean(x);
theta = zeros(p,p);
for i = 1:p
   for j = 1:p
      for k = 1:n
         theta(i,j) = theta(i,j) +...
            ((x(k,i) - mu(i))*(x(k,j) - mu(j)) - S(i,j))^2;
      end
   end
end
theta = theta/n;
