% RANKTEST                    Rank-based tests high-dimensional independence
% 
%     [pval,r,rmc] = ranktest(x,varargin)
%
%     Given a sample X1,...,Xn from a p-dimensional multivariate distribution,
%     test the hypothesis:
%
%     H0 : X1,...,Xp are mutually independent
%
%     INPUTS
%     x    - [n x p] matrix, n samples with dimensionality p
%
%     OPTIONAL (name/value pairs)
%     test - 'spearman' - R1 from Han & Liu (default)
%            'kendall'  - R2 from Han & Liu 
%     empirical - boolean to monte-carlo sample null distribution
%                 DEFAULT=FALSE, which uses asymptotic distribution
%     nmc - number of monte-carlo samples, if empirical=true
%     rmc - vector of monte-carlo samples. Since the null distribution is
%           distribution-free (does not depend on data other than size), if
%           you have already estimated the empirical, you can avoid doing
%           it again
%
%     OUTPUTS
%     pval - p-value
%     r    - rank statistic
%     rmc  - monte-carlo samples of empirical null
%
%     REFERENCE
%     Han & Liu (2014). Distribution-free tests of independence with
%       applications to testing more structures. arXiv:1410.4179v1
%
%     SEE ALSO
%     rank, DepTest1

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

function [pval,r,rmc] = ranktest(x,varargin)

par = inputParser;
par.KeepUnmatched = true;
addRequired(par,'x',@isnumeric);
addParamValue(par,'test','spearman',@ischar);
addParamValue(par,'empirical',false,@(x) isnumeric(x) || islogical(x));
addParamValue(par,'nmc',1000,@(x) isnumeric(x) && isscalar(x));
addParamValue(par,'rmc',[],@isnumeric);
parse(par,x,varargin{:});

[n,p] = size(x);
r = dep.rank(x,par.Results.test);

if par.Results.empirical
   nmc = par.Results.nmc;
   rmc = par.Results.rmc;
   if isempty(rmc)
      rmc = zeros(nmc,1);
   else
      pval = sum(rmc>=r)/nmc;
      return;
   end
   % Otherwise re-estimate, TODO: check whether this depends on n,p?
   for i = 1:nmc
      xmc = randn(n,p);
      rmc(i) = dep.rank(xmc,par.Results.test);
   end
   pval = sum(rmc>=r)/nmc;
else
   % Asymptotic, extreme value type 1 cdf
   cdf = @(y) exp(-exp(-y/2)/sqrt(8*pi));
   pval = 1 - cdf(r);
   rmc = [];
end