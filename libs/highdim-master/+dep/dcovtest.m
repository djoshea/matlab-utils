% DCOVTEST                    Distance covariance test of independence
% 
%     [pval,r,stat,null] = dcovtest(x,y,varargin)
%
%     Given a sample X1,...,Xn from a p-dimensional multivariate distribution,
%     and a sample Y1,...,Xn from a q-dimensional multivariate distribution,
%     test the hypothesis:
%
%     H0 : X and Y are mutually independent
%
%     This hypothesis is tested using several different permutation methods. 
%
%     The default permutation method avoids permuting the data altogether 
%     by approximating the permutation distribution using a moment-matched 
%     Pearson Type III distribution (Bilodeau & Guetsop Nangue 2017; Josse 
%     et al 2008; Minas & Montana 2014). The first three moments of the 
%     permutation distribution can be calculated exactly for distance 
%     covariance and related statistics (Kazi-Aoual et al 1995), and the 
%     Pearson type III fit using these moments is a robust and accurate 
%     approximation to the null distribution (Josse et al 2008). Since this 
%     method does not actually permute the data, it is very fast, achieving 
%     the same statistical power that would otherwise require millions of 
%     permutations (Minas & Montana, 2014).
%
%     Testing using actual permutations of the data are also implemented.
%     Naive permutation of the rows of X or Y is expensive due to O(n^2) 
%     distance calculations. This can be avoided since it is equivalent to 
%     simultaneously permuting the rows and columns of the distance matrix, 
%     and recomputing the statistic with the permuted distance matrix.
%
%     INPUTS
%     x - [n x p] n samples of dimensionality p
%     y - [n x q] n samples of dimensionality q
%
%     OPTIONAL (as name/value pairs, order irrelevant)
%     method - 'pearson'    - Pearson type III approx by moment matching (DEFAULT)
%              'perm'       - randomization using permutation of the rows &
%                             columns of the double-centered distance matrices
%              'perm-dist'  - randomization using permutation of the rows &
%                             columns of distance matrices
%              'perm-brute' - brute force randomization, directly permuting
%                             one of the inputs, which requires recalculating 
%                             and centering distance matrices
%     nboot - # permutations if method != 'pearson'
%
%     OUTPUTS
%     pval - p-value
%     d    - distance covariance
%     stat - test statistic
%     null - permutation statistics
%
%     EXAMPLE
%     rng(1234);
%     p = 100;
%     n = 2000;
%     X = rand(n,p);  Y = X.^2 + 15*randn(n,p);
%
%     tic;[pval,d] = dep.dcovtest(X,Y,'method','pearson'); toc
%     [pval, d]
%     tic;[pval,d] = dep.dcovtest(X,Y,'method','pearson','unbiased',true); toc
%     [pval, d]
%     tic;[pval,d] = dep.dcovtest(X,Y,'method','perm','nboot',200);toc
%     [pval, d]
%     tic;[pval,d] = dep.dcovtest(X,Y,'method','perm-brute','nboot',200);toc
%     [pval, d]
%
%     REFERENCE
%     Bilodeau & Guetsop Nangue (2017). Approximations to permutation tests 
%       of independence between two random vectors. 
%       Computational Statistics & Data Analysis, submitted.
%     Josse, Pages & Husson (2008). Testing the significance of the RV 
%       coefficient. Computational Statistics and Data Analysis. 53: 82-91
%     Kazi-Aoual et al (1995). Refined approximations to permutation tests 
%       for multivariate inference. Computational Statistics & Data Analysis.
%       20: 643-656
%     Minas & Montana (2014). Distance-based analysis of variance: 
%       Approximate inference. Statistical Analysis & Data Mining. 7: 450-470
%
%     SEE ALSO
%     dcov, dcorr, dcorrtest, DepTest2

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

function [pval,d,stat,varargout] = dcovtest(x,y,varargin)

par = inputParser;
par.KeepUnmatched = true;
addRequired(par,'x',@isnumeric);
addRequired(par,'y',@isnumeric);
addParamValue(par,'method','pearson',@ischar);
addParamValue(par,'nboot',999,@(x) isnumeric(x) && isscalar(x));
parse(par,x,y,varargin{:});

[n,~] = size(x);
assert(n == size(y,1),'DCOVTEST requires x and y to have the same # of samples');

permMethods = {'perm' 'perm-dist' 'perm-brute'};
nboot = par.Results.nboot;
method = lower(par.Results.method);

switch method
   case {'pearson'}
      [d,~,~,A,B] = dep.dcov(x,y,par.Unmatched);
      
      if isfield(par.Unmatched,'unbiased') && par.Unmatched.unbiased
         stat = (n*(n-3))*d; %  = sum(sum(A.*B)) for unbiased estimator
      else
         stat = (n^2)*d^2; %  = sum(sum(A.*B)) for biased estimator
      end
      
      [pval,stat] = utils.pearsonIIIpval(A,B,stat);      
   case {'perm'}
      if isfield(par.Unmatched,'unbiased') && par.Unmatched.unbiased
         % This only works for BIASED estimator, since distance matrices are
         % necessary for calculating the UNBIASED estimator
         error('Cannot use unbiased estimator for method = ''perm''');
      end
      [d,~,~,A,B] = dep.dcov(x,y);

      null = zeros(nboot,1);
      for i = 1:nboot
         ind = randperm(n);
         null(i) = dep.dcov(A,B(ind,ind),'doublecenter',true);
      end
   case {'perm-dist'}
      a = sqrt(utils.sqdist(x,x));
      b = sqrt(utils.sqdist(y,y));
      d = dep.dcov(a,b,'dist',true);
      
      null = zeros(nboot,1);
      for i = 1:nboot
         ind = randperm(n);
         null(i) = dep.dcov(a,b(ind,ind),'dist',true);
      end
   case {'perm-brute'}
      d = dep.dcov(x,y,par.Unmatched);

      null = zeros(nboot,1);
      for i = 1:nboot
         ind = randperm(n);
         null(i) = dep.dcov(x,y(ind,:),par.Unmatched);
      end
   otherwise
      error('Unrecognized test method');
end

% One of the permutation methods
if any(strcmp(method,permMethods))
   if ~exist('stat','var')
      stat = d;
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