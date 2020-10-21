% DEPTEST1                    Interface for one-sample tests
%
%     Given a sample X1,...,Xn from a p-dimensional multivariate distribution,
%     test one of the hypotheses:
%
%     H0 : Covariance matrix of sample is proportional to the identity
%     
%     using the following tests,
%        'john'  - John, Sugiura, Nagao test (JSN)
%        'nagao' - JSN with Box-Bartlett correction
%        'wang'  - JSN with correction for large p
%        'sign'  - multivariate sign, non-parametric
%        'bcs'   - multivariate sign, correction for large p
%
%     H0 : X1,...,Xp are mutually independent
%
%     using the following rank-based tests suitable for high-dimensional data
%        'spearman' - R1 from Han & Liu (default)
%        'kendall'  - R2 from Han & Liu 
%
%     PROPERTIES
%     x       - [n x p] matrix, n samples with dimensionality p
%     n       - # of samples
%     p       - # of dimensions
%     test    - string (see above, default = 'bcs')
%     params  - parameters passed through for specific tests
%     alpha   - alpha level (default = 0.05)
%     stat    - corresponding statistic
%     pval    - p-value
%     h       - boolean, 1 indicates rejection of null at alpha
%     runtime - elapsed time for running test, in seconds
%
%     EXAMPLE
%     % Independent, but non-spherical data
%     sigma = diag([ones(1,25),0.5*ones(1,5)]);
%     x = (sigma*randn(50,30)')';
%     % Sphericity tests
%     DepTest1(x,'test','john')
%     DepTest1(x,'test','wang')
%     DepTest1(x,'test','sign')
%     DepTest1(x,'test','bcs')
%     % Independence tests
%     DepTest1(x,'test','spearman')
%     DepTest1(x,'test','kendall')
%
%     REFERENCE
%     Han & Liu (2014). Distribution-free tests of independence with
%       applications to testing more structures. arXiv:1410.4179v1
%     Ledoit & Wolf (2002). Some hypothesis tests for the covariance matrix
%       when the dimension is large compared to the sample size. Annals of 
%       Statistics 30: 1081-1102   
%     Wang, Q and Yao J (2013). On the sphericity test with large-dimensional
%       observations. Electronic Journal of Statistics 7: 2164-2192
%     Zou et al (2014). Multivariate sign-based high-dimensional tests for
%       sphericity. Biometrika 101: 229-236
%
%     SEE ALSO
%     DepTest2, UniSphereTest

%     $ Copyright (C) 2017 Brian Lau, brian.lau@upmc.fr $
%     The full license and most recent version of the code can be found
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

classdef DepTest1 < handle
   properties
      x
   end
   properties (Dependent=true,SetAccess=private)
      n
      p
   end
   properties
      test
      params
      alpha = 0.05;
   end
   properties (SetAccess=private)
      stat
      pval
      h
      runtime
   end
   properties (Hidden=true,SetAccess=private)
      mc % monte carlo samples of empirical null distribution
      autoRun
      validTests = {'spearman' 'kendall' 'sign' 'bcs' ...
         'john' 'nagao' 'wang'};
   end
   properties(SetAccess = protected)
      version = '0.1.0'
   end
   
   methods
      function self = DepTest1(varargin)
         if (nargin == 1) || (rem(nargin,2) == 1)
            varargin = {'x' varargin{:}};
         end
         
         par = inputParser;
         par.KeepUnmatched = true;
         addParamValue(par,'x',[],@isnumeric);
         addParamValue(par,'autoRun',true,@islogical);
         addParamValue(par,'test','spearman',@ischar);
         parse(par,varargin{:});

         self.autoRun = par.Results.autoRun;
         self.params = par.Unmatched;
         self.test = par.Results.test;
         self.x = par.Results.x;
      end
      
      function set.x(self,x)
         [n,p] = size(x);
         % Clear cache of monte-carlo samples if dimensions change
         % Only applies for rank-based tests of independence
         if (self.n~=n) || (self.p~=p)
            self.mc = [];
         end
         self.x = x;
         if ~isempty(self.x) && self.autoRun
            self.run();
         end
      end
      
      function set.test(self,test)
         test = lower(test);
         if any(strcmp(test,self.validTests))
            self.test = test;
            if ~isempty(self.x) && self.autoRun
               self.run();
            end
         else
            error('Invalid test');
         end
      end
      
      function set.params(self,params)
         self.params = params;
         if ~isempty(self.x) && self.autoRun
            self.run();
         end
      end
      
      function set.alpha(self,alpha)
         assert((alpha>0)&&(alpha<1),'0<alpha<1');
         self.alpha = alpha;
      end
            
      function n = get.n(self)
         n = size(self.x,1);
      end
      
      function p = get.p(self)
         p = size(self.x,2);
      end
      
      function h = get.h(self)
         h = self.pval<self.alpha;
      end
      
      function run(self)
         tic;
         switch self.test
            case {'spearman','kendall'}
               if isempty(self.mc)
                  [self.pval,self.stat,mc] = ...
                     dep.ranktest(self.x,'test',self.test,self.params);
                  % Cache the monte-carlo samples, these rank-tests are
                  % distribution free (do not depend on input distribution)
                  self.mc = mc;
               else
                  [self.pval,self.stat] = ...
                     dep.ranktest(self.x,'test',self.test,'rmc',self.mc,self.params);
               end
            case {'sign','bcs'}
               [self.pval,self.stat] = ...
                  sphere.signtest(self.x,'test',self.test,self.params);
            case {'john','nagao','wang'}
               [self.pval,self.stat] = ...
                  sphere.jsn(self.x,'test',self.test,self.params);
            otherwise
               % Never
         end
         self.runtime = toc;
      end
   end
end
