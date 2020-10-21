% UNISPHERETEST               Test uniform distribution on unit hypersphere 
% 
%     Given a sample X1,...,Xn from a p-dimensional multivariate distribution,
%     test the hypothesis:
%
%     H0 : Sample is uniformly distributed on the unit hypersphere (S_{p-1})
%     
%     using the following tests,
%        'rayleigh'  - Rayleigh test, parametric (default)
%        'gine'      - Gine test
%        'gine3'     - Gine test with fast approximation for p = 3
%        'bingham'   - Bingham test
%        'ajne'      - Ajne test, non-parametric
%        'gine-ajne' - Weighted Gine/Ajne test, non-parametric
%        'randproj'  - Random projection test, non-parametric
%
%     PROPERTIES
%     x       - [n x p] matrix, n samples with dimensionality p
%     n       - # of samples
%     p       - # of dimensions
%     test    - string (see above, default = 'rayleigh')
%     params  - parameters passed through for specific tests
%     alpha   - alpha level (default = 0.05)
%     stat    - corresponding statistic
%     pval    - p-value
%     h       - boolean, 1 indicates rejection of null at alpha
%     runtime - elapsed time for running test, in seconds
%
%     EXAMPLE
%     sigma = diag([1 5 1]);
%     x = (sigma*randn(50,3)')';
%     % Note failure of Rayleigh test, since resultant is zero
%     UniSphereTest(x,'test','rayleigh') 
%     UniSphereTest(x,'test','gine-ajne') 
%     UniSphereTest(x,'test','randproj') 
%     UniSphereTest(x,'test','bingham') 
%
%     REFERENCE
%     Cai, T et al (2013). Distribution of angles in random packing on
%       spheres. J of Machine Learning Research 14: 1837-1864.
%     Cuesta-Albertos, JA et al (2009). On projection-based tests for 
%       directional and compositional data. Stat Comput 19: 367-380
%     Mardia, KV, Jupp, PE (2000). Directional Statistics. John Wiley
%     Prentice, MJ (1978). On invariant tests of uniformity for directions
%       and orientations. Annals of Statistics 6: 169-176.
%
%     SEE ALSO
%     DepTest1, DepTest2

%     $ Copyright (C) 2017 Brian Lau, brian.lau@upmc.fr$
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

classdef UniSphereTest < handle
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
      autoRun
      validTests = {'rayleigh' 'gine' 'gine3' 'ajne' ...
         'gine-ajne' 'bingham' 'randproj'};
   end
   properties(SetAccess = protected)
      version = '0.1.0'
   end
   
   methods
      function self = UniSphereTest(varargin)
         if (nargin == 1) || (rem(nargin,2) == 1)
            varargin = {'x' varargin{:}};
         end
         
         par = inputParser;
         par.KeepUnmatched = true;
         addParamValue(par,'x',[],@isnumeric);
         addParamValue(par,'autoRun',true,@islogical);
         addParamValue(par,'test','rayleigh',@ischar);
         parse(par,varargin{:});

         self.autoRun = par.Results.autoRun;
         self.params = par.Unmatched;
         if ~isfield(self.params,'nboot')
            self.params.nboot = 1000;
         end
         self.test = par.Results.test;
         self.x = par.Results.x;
      end
      
      function set.x(self,x)
         [n,p] = size(x);
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
         U = sphere.spatialSign(self.x);
         tic;
         switch self.test
            case {'rayleigh'}
               [self.pval,self.stat] = sphere.rayleigh(U);
            case {'gine'}
               self.stat = sphere.gine(U);
               [self.pval,boot] = ...
                  self.bootstrap('sphere.gine',self.params.nboot,self.n,self.p,self.stat);
            case {'gine3'}
               [self.pval,self.stat] = sphere.gine3(U);
            case {'ajne'}
               self.stat = sphere.ajne(U);
               [self.pval,boot] = ...
                  self.bootstrap('sphere.ajne',self.params.nboot,self.n,self.p,self.stat);
            case {'gine-ajne'}
               self.stat = sphere.gineajne(U);
               [self.pval,boot] = ...
                  self.bootstrap('sphere.gineajne',self.params.nboot,self.n,self.p,self.stat);
            case {'bingham'}
               [self.pval,self.stat] = sphere.bingham(U);
            case {'randproj'}
               [self.pval,self.stat] = sphere.rptest(U,self.params);
            otherwise
               % Never
         end
         self.runtime = toc;
      end
   end
   
   methods (Static)
      function [pval,boot] = bootstrap(f,nboot,n,p,stat)
         boot = zeros(nboot,1);
         for j = 1:nboot
            Umc = sphere.spatialSign(randn(n,p));
            boot(j) = feval(f,Umc);
         end
         pval = sum(boot>=stat)/nboot;
      end
   end
end