% RANK                        Rank-based statistics for testing independence
% 
%     r = rank(x,type)
%
%     INPUTS
%     x    - [n x p] matrix, n samples with dimensionality p
%
%     OPTIONAL
%     type - 'spearman' - R1 from Han & Liu (DEFAULT)
%            'kendall' - R2 from Han & Liu
%
%     OUTPUTS
%     r - rank statistic
%
%     REFERENCE
%     Han & Liu (2014). Distribution-free tests of independence with
%       applications to testing more structures. arXiv:1410.4179v1
%
%     SEE ALSO
%     DepTest1, ranktest

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

function r = rank(x,type)

if nargin < 2
   type = 'spearman';
end

[n,p] = size(x);

switch lower(type)
   case {'spearman','s'}
      rho = corr(x,'type','spearman');
      rho2 = rho.^2;
      rho2 = tril(rho2,-1);
      r = (n-1)*max(rho2(:)) - 4*log(p) + log(log(p));
   case {'kendall','k'}
      %tau = corr(x,'type','kendall');
      tau = dep.kendalltau(x);
      tau2 = tau.^2;
      tau2 = tril(tau2,-1);
      r = ((9*n*(n-1))/(2*(2*n+5)))*max(tau2(:)) - 4*log(p) + log(log(p));
   otherwise
      error('Unknown type');
end