% DCORRTEST                   Distance correlation test of independence
% 
%     [pval,r,stat,null] = dcorrtest(x,y,varargin)
%
%     Given a sample X1,...,Xn from a p-dimensional multivariate distribution,
%     and a sample Y1,...,Xn from a q-dimensional multivariate distribution,
%     test the hypothesis:
%
%     H0 : X and Y are mutually independent
%
%     The default test is based on a modified distance correlation statistic 
%     that when suitably transformed converges to a Student t distribution 
%     under independence (Szekely & Rizzo 2013). The resulting t-test is 
%     unbiased for sample sizes greater than three and all significance 
%     levels. 
%
%     Several different permutation methods are also available. See DCOVTEST
%     for details. These are included mostly for testing since the t-test
%     is well-behaved even in small samples, and very computationally efficient.
%
%     INPUTS
%     x - [n x p] n samples of dimensionality p
%     y - [n x q] n samples of dimensionality q
%
%     OPTIONAL (as name/value pairs, order irrelevant)
%     method - 't'          - t-test from Szekely & Rizzo (2013), DEFAULT 
%              'pearson'    - Pearson type III approx by moment matching
%              'perm-dist'  - randomization using permutation of the rows &
%                             columns of distance matrices
%              'perm-brute' - brute force randomization, directly permuting
%                             one of the inputs, which requires recalculating 
%                             and centering distance matrices
%     nboot - # permutations if not t-test
%
%     OUTPUTS
%     pval - p-value
%     r    - distance correlation
%     stat - test statistic
%     null - permutation statistics
%
%     EXAMPLE
%     rng(1234);
%     p = 100;
%     n = 2000;
%     X = rand(n,p);  Y = X.^2 + 15*randn(n,p);
%
%     tic;[pval,r] = dep.dcorrtest(X,Y); toc % default t-test
%     [pval , r]
%     tic;[pval,r] = dep.dcorrtest(X,Y,'method','pearson'); toc
%     [pval , r]
%     tic;[pval,r] = dep.dcorrtest(X,Y,'method','perm-dist','nboot',200);toc
%     [pval , r]
%     tic;[pval,r] = dep.dcorrtest(X,Y,'method','perm-brute','nboot',200);toc
%     [pval , r]
%
%     REFERENCE
%     Szekely et al (2007). Measuring and testing independence by correlation 
%       of distances. Ann Statist 35: 2769-2794
%     Szekely & Rizzo (2013). The distance correlation t-test of independence 
%       in high dimension. J Multiv Analysis 117: 193-213
%
%     SEE ALSO
%     dcorr, DepTest2

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

function [pval,r,stat,varargout] = dcorrtest(x,y,varargin)

par = inputParser;
par.KeepUnmatched = true;
addRequired(par,'x',@isnumeric);
addRequired(par,'y',@isnumeric);
addParamValue(par,'method','t',@ischar);
addParamValue(par,'nboot',999,@(x) isnumeric(x) && isscalar(x));
parse(par,x,y,varargin{:});

[n,~] = size(x);
assert(n == size(y,1),'DCORRTEST requires x and y to have the same # of samples');

permMethods = {'perm-dist' 'perm-brute'};
nboot = par.Results.nboot;
method = lower(par.Results.method);

switch method
   case {'pearson'}
      if ~isfield(par.Unmatched,'unbiased')
         % Override dcov default, we generally want unbiased dcorr
         [d,dvx,dvy,A,B] = dep.dcov(x,y,'unbiased',true,par.Unmatched);
      else
         [d,dvx,dvy,A,B] = dep.dcov(x,y,par.Unmatched);
      end
      r = d/sqrt(dvx*dvy);
      
      if isfield(par.Unmatched,'unbiased') && par.Unmatched.unbiased
         stat = (n*(n-3))*d; %  = sum(sum(A.*B)) for unbiased estimator
      elseif ~isfield(par.Unmatched,'unbiased')
         stat = (n*(n-3))*d; %  = sum(sum(A.*B)) for unbiased estimator
      else
         stat = (n^2)*d^2; %  = sum(sum(A.*B)) for biased estimator
      end
      
      [pval,stat] = utils.pearsonIIIpval(A,B,stat);
      return;
   case {'t','ttest','t-test'}
      if isfield(par.Unmatched,'unbiased') && ~par.Unmatched.unbiased
         error('This method is only valid for UNBIASED estimator');
      elseif ~isfield(par.Unmatched,'unbiased')
         r = dep.dcorr(x,y,'unbiased',true,par.Unmatched);
      else
         r = dep.dcorr(x,y,par.Unmatched);
      end
      
      v = n*(n-3)/2;
      stat = sqrt(v-1) * r/sqrt(1-r^2);
      pval = tcdf(stat,v-1,'upper');
      return;
   case {'perm-dist'}      
      a = sqrt(utils.sqdist(x,x));
      b = sqrt(utils.sqdist(y,y));
      [d,dvx,dvy] = dep.dcov(a,b,'dist',true,'unbiased',true);
      r = d/sqrt(dvx*dvy);

      null = zeros(nboot,1);
      for i = 1:nboot
         ind = randperm(n);
         [d2,dvx2,dvy2] = dep.dcov(a,b(ind,ind),'dist',true,'unbiased',true);
         null(i) = d2/sqrt(dvx2*dvy2);
      end
   case {'perm-brute'}
      [d,dvx,dvy] = dep.dcov(x,y,'unbiased',true);
      r = d/sqrt(dvx*dvy);

      null = zeros(nboot,1);
      for i = 1:nboot
         ind = randperm(n);
         [d2,dvx2,dvy2] = dep.dcov(x,y(ind,:),'unbiased',true);
         null(i) = d2/sqrt(dvx2*dvy2);
      end
   otherwise
      error('Unrecognized test method');
end

% One of the permutation methods
if any(strcmp(method,permMethods))
   if ~exist('stat','var')
      stat = r;
   end
   pval = (1 + sum(null>stat)) / (1 + nboot);
end

if nargout == 4
   if exist('null','var')
      varargout{1} = null;
   else
      varargout{1} = [];
   end
end