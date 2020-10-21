% RPTEST               Random projection test for spherical uniformity 
% 
%     [pval,stat] = rptest(U,varargin)
%
%     INPUTS
%     U - [n x p] matrix, n samples with dimensionality p
%         the data should already be projected to the unit hypersphere
%
%     OPTIONAL
%     test - 
%
%     OUTPUTS
%     pval - p-value
%     stat - statistic, projections onto k random p-vectors
%
%     REFERENCE
%     Cuesta-Albertos, JA et al (2009). On projection-based tests for 
%       directional and compositional data. Stat Comput 19: 367-380
%     Cuesta-Albertos, JA et al (2007). A sharp form of the Cramer-Wold 
%       theorem. J Theor Probab 20: 201-209
%
%     SEE ALSO
%     UniSphereTest, rp, rppdf, rpcdf

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

function [pval,stat] = rptest(U,varargin)

import sphere.*

par = inputParser;
par.KeepUnmatched = true;
addRequired(par,'U',@isnumeric);
addParamValue(par,'correction','fdr',@ischar);
addParamValue(par,'nmc',2000,@isnumeric);
addParamValue(par,'k',20,@isnumeric);
addParamValue(par,'dist','empirical',@ischar);
parse(par,U,varargin{:});
k = par.Results.k;

[n,p] = size(U);
stat = rp(U,k);

switch lower(par.Results.dist)
   case 'asymp'
      pval = zeros(k,1);
      for i = 1:k
         test_cdf = [ stat(:,i) , rpcdf(stat(:,i),p)];
         [~,pval(i)] = kstest(stat(:,i),'CDF',test_cdf);
      end
   otherwise % empirical
      Umc = spatialSign(randn(par.Results.nmc,p));
      u0 = spatialSign(randn(1,p));
      Ymc = acos(Umc*u0');
      pval = zeros(k,1);
      for i = 1:k
         [~,pval(i)] = kstest2(stat(:,i),Ymc);
      end
end

switch lower(par.Results.correction)
   case 'bonferroni'
      adj_p = pval*k;
   case 'fdr'
      [~,~,adj_p] = utils.fdr_bh(pval,.05,'pdep');
   otherwise
      error('Invalid p-value correction');
end
pval = min(adj_p);
