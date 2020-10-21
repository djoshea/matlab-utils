% MINENTEST                  N-dimensional, 2-sample comparison of 2 distributions
% 
%     [p,e_n,e_n_boot] = minentest(x,y,varargin)
%
%     Compares d-dimensional data from two samples using a measure based on
%     statistical energy. The test is non-parametric, does not require binning
%     and easily scales to arbitrary dimensions.
%
%     The analytic distribution of the statistic is unknown, and p-values
%     are estimated using a permutation procedure, which works well
%     according to simulations by Aslan & Zech.
%
%     INPUTS
%     x     - [n1 x d] matrix
%     y     - [n2 x d] matrix
%
%     OPTIONAL (name/value pairs)
%     flag  - 'sr', Szekely & Rizzo energy statistic 
%             'az', Aslan & Zech energy statistic (default)
%     nboot - # of bootstrap resamples (default = 1000)
%     replace - boolean for sampling with replacement (default = false)
%
%     OUTPUTS
%     p    - p-value by permutation
%     e_n  - minimum energy statistic
%     e_n_boot - bootstrap samples
%
%     REFERENCE
%     Aslan, B, Zech, G (2005) Statistical energy as a tool for binning-free
%       multivariate goodness-of-fit tests, two-sample comparison and unfolding.
%       Nuc Instr and Meth in Phys Res A 537: 626-636
%     Szekely, G, Rizzo, M (2014) Energy statistics: A class of statistics
%       based on distances. J Stat Planning & Infer 143: 1249-1272
%
%     SEE ALSO
%     kstest2d, hotell2, DepTest2

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
%
%     REVISION HISTORY:
%     brian 08.25.11 written

% TODO 
%  o calculate distance matrix once and cache, permute index
%    attempted once, https://github.com/brian-lau/multdist/commit/ae58496848464cea50fe134ab6f1e2f929632c88
%  o k-sample version
%  o incomplete V-statistic


function [p,e_n,e_n_boot] = minentest(x,y,varargin)

par = inputParser;
par.KeepUnmatched = true;
addRequired(par,'x',@isnumeric);
addRequired(par,'y',@isnumeric);
addParamValue(par,'flag','sr',@ischar);
addParamValue(par,'nboot',1000,@(x) isscalar(x)&&isnumeric(x));
addParamValue(par,'replace',false,@(x) islogical(x)||isnumeric(x));
parse(par,x,y,varargin{:});

[n,ny] = size(x);
[m,my] = size(y);

if ny ~= my
   error('# of columns in X and Y must match');
end

pooled = [x ; y];

flag = par.Results.flag;
nboot = par.Results.nboot;
replace = par.Results.replace;
e_n = energy(x,y,flag);
e_n_boot = zeros(nboot,1);
e_n_boot(1) = e_n;
for i = 2:nboot
   if replace
      ind = unidrnd(n+m,1,n+m);
   else
      ind = randperm(n+m);
   end
   e_n_boot(i) = energy(pooled(ind(1:n),:),pooled(ind(n+1:end),:),flag);
end

p = sum(e_n_boot>=e_n)./nboot;

function [dx,dy,dxy] = dist(x,y)
dx = pdist(x,'euclidean');
dy = pdist(y,'euclidean');
dxy = pdist2(x,y,'euclidean');

function z = energy(x,y,flag)
% FIXME, equal samples will generate infinite values, will produce
% unreliable results, more of a problem for discrete data.
n = size(x,1);
m = size(y,1);
[dx,dy,dxy] = dist(x,y);
switch flag
   case 'az'
      % Aslan & Zech definition of energy statistic 
      z = (1/(n*(n-1)))*sum(-log(dx)) + (1/(m*(m-1)))*sum(-log(dy))...
         - (1/(n*m))*sum(-log(dxy(:)));
   case 'sr'
      % Szekely & Rizzo definition of energy statistic
      % Verified against their R package 'energy'
      % in R:
      %   data(iris)
      %   eqdist.etest(iris[,1:4], c(75,75), R = 199)
      %   E-statistic = 126.0453, p-value = 0.005
      % in Matlab:
      %   load fisheriris;
      %   [p,en] = minentest(meas(1:75,:),meas(76:end,:),'sr',200)
      z = (2/(n*m))*sum(dxy(:)) - (1/(n^2))*sum(2*dx) - (1/(m^2))*sum(2*dy);
      z = ((n*m)/(n+m)) * z;
   otherwise
      error('Bad FLAG');
end