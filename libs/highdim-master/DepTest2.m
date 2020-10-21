% DEPTEST2                    Interface for two-sample (in)dependence tests
%
%     Given a sample X1,...,Xm from a p-dimensional multivariate distribution,
%     and a sample Y1,...,Xn from a q-dimensional multivariate distribution,
%     test one of the hypotheses:
%
%     H0 : X and Y are drawn from the same distribution
%     
%     using the following tests,
%        'mmd'       - Maximal Mean Discrepancy
%        'energy'    - Szekely & Rizzo energy test
%        'ks'        - Two-dimensional Kolmorogov-Smirnov test
%
%     H0 : X and Y are mutually independent
%
%     using the following tests,
%        'dcorr'     - distance correlation (default)
%        'rv'        - RV coefficient
%        'hsic'      - Hilbert-Schmidt Independence Criterion
%
%     H0 : X and Y have the same mean
%     
%     using the following tests,
%        'hotelling' - Hotelling T^2 test
%        'randsub'   - random subspace
%
%     H0 : cov(X) = cov(Y)
%     
%     using the following tests,
%        'covdiff'   - Cai et al. test for difference in covariance matrices
%
%     PROPERTIES
%     x       - [m x p] matrix, m samples with dimensionality p
%     y       - [n x q] matrix, n samples with dimensionality q
%     m       - # of x samples
%     p       - # of x dimensions
%     n       - # of y samples
%     q       - # of y dimensions
%     test    - string (see above, default = 'dcorr')
%     params  - parameters passed through for specific tests
%     alpha   - alpha level (default = 0.05)
%     stat    - corresponding statistic
%     pval    - p-value
%     h       - boolean, 1 indicates rejection of null at alpha
%     runtime - elapsed time for running test, in seconds
%
%     EXAMPLE
%     % non-indepedent data, with ~0 correlation
%     x = rand(200,1); y = rand(200,1);
%     xx = 0.5*(x+y)-0.5; yy = 0.5*(x-y);
%     corr(xx,yy)
%     % independence test
%     DepTest2(xx,yy,'test','dcorr')
%     DepTest2(xx,yy,'test','hsic')
%     % same distribution?
%     DepTest2(xx,yy,'test','mmd')
%     DepTest2(xx,yy,'test','energy')
% 
%     % independent data, different distribution
%     x = randn(200,1); y = rand(200,1);
%     % independence test
%     DepTest2(x,y,'test','dcorr')
%     DepTest2(x,y,'test','hsic')
%     % same distribution?
%     DepTest2(x,y,'test','mmd')
%     DepTest2(x,y,'test','energy')
%
%     REFERENCE
%     Gretton et al (2008). A kernel statistical test of independence. NIPS
%     Szekely et al (2007). Measuring and testing independence by correlation 
%       of distances. Ann Statist 35: 2769-2794
%     Szekely & Rizzo (2013). The distance correlation t-test of independence 
%       in high dimension. J Multiv Analysis 117: 193-213
%
%     SEE ALSO
%     DepTest1, UniSphereTest

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

classdef DepTest2 < handle
   properties
      x
      y
   end
   properties (Dependent=true,SetAccess=private)
      m
      p
      n
      q
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
      autoRun
      validTests = {'dcorr' 'rv' 'hsic'...
         'mmd' 'energy' 'hotelling' 'ks' 'covdiff'};
   end
   properties(SetAccess = protected)
      version = '0.1.0'
   end
   
   methods
      function self = DepTest2(varargin)
         if (nargin == 2)
            varargin = {'x' varargin{1} 'y' varargin{2}};
         elseif isnumeric(varargin{1}) && isnumeric(varargin{2})
            varargin = {'x' varargin{1} 'y' varargin{2} varargin{3:end}};
         end
         
         par = inputParser;
         par.KeepUnmatched = true;
         addParamValue(par,'x',[],@isnumeric);
         addParamValue(par,'y',[],@isnumeric);
         addParamValue(par,'autoRun',true,@islogical);
         addParamValue(par,'test','dcorr',@ischar);
         parse(par,varargin{:});

         self.autoRun = par.Results.autoRun;
         self.params = par.Unmatched;
         self.test = par.Results.test;
         self.replaceData(par.Results.x,par.Results.y);
      end
      
      function replaceData(self,x,y)
         old = self.autoRun;
         self.autoRun = false;
         self.x = x;
         self.y = y;
         self.autoRun = old;
         if ~isempty(self.x) && ~isempty(self.y) && self.autoRun
            self.run();
         end
      end
      
      function set.x(self,x)
         self.x = x;
         if ~isempty(self.x) && ~isempty(self.y) && self.autoRun
            self.run();
         end
      end
      
      function set.y(self,y)
         self.y = y;
         if ~isempty(self.x) && ~isempty(self.y) && self.autoRun
            self.run();
         end
      end
      
      function set.test(self,test)
         test = lower(test);
         if any(strcmp(test,self.validTests))
            self.test = test;
            if ~isempty(self.x) && ~isempty(self.y) && self.autoRun
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
            
      function m = get.m(self)
         m = size(self.x,1);
      end
      
      function n = get.n(self)
         n = size(self.y,1);
      end
      
      function p = get.p(self)
         p = size(self.x,2);
      end
      
      function q = get.q(self)
         q = size(self.y,2);
      end
      
      function h = get.h(self)
         h = self.pval<self.alpha;
      end
      
      function run(self)
         tic;
         switch self.test
            case {'dcorr'}
               [self.pval,self.stat] = ...
                  dep.dcorrtest(self.x,self.y,self.params);
            case {'hsic'}
               [self.pval,self.stat] = ...
                  dep.hsictest(self.x,self.y,self.params);
            case {'rv'}
               [self.pval,self.stat] = ...
                  dep.rvtest(self.x,self.y);
            case {'mmd'}
               [self.pval,self.stat] = ...
                  diff.mmdtest(self.x,self.y,self.params);
            case{'ks'}
               [self.pval,self.stat] = diff.kstest2d(self.x,self.y);
            case{'hotelling'}
               [self.pval,self.stat] = diff.hotell2(self.x,self.y);
            case{'covdiff'}
               [self.pval,self.stat] = diff.covtest(self.x,self.y);
             case{'energy'}
               [self.pval,self.stat] = ...
                  diff.minentest(self.x,self.y,self.params);
           otherwise
               % Never
         end
         self.runtime = toc;
      end
   end
end
