% JSN                  John, Sugiura, Nagao test of high-deminsional sphericity
% 
%     [pval,stat] = jsn(x,varargin)
%
%     Given a sample X1,...,Xn from a p-dimensional multivariate distribution,
%     test the hypothesis:
%
%     H0 : Covariance matrix of sample is proportional to the identity
%
%     This test is the locally most powerful invariant test for sphericity,
%     is n-consistent, and remains valid even when n and p grow together
%     (method='john' or 'nagao'). Moreover, the n,p-consistent variant
%     (method = 'wang') only requires the existence of fourth moments.
%
%     INPUTS
%     x    - [n x p] matrix, n samples with dimensionality p
%
%     OPTIONAL (name/value pairs)
%     test - 'john' - fixed p, n goes to infinity (DEFAULT)
%            'nagao' - Box-Bartlett like refinements to asymptotic dist
%            'wang' - p,n -> inf, p/n -> y>0, universal
%
%     OUTPUTS
%     pval - p-value
%     stat - statistic
%
%     REFERENCE
%     Ledoit & Wolf (2002). Some hypothesis tests for the covariance matrix
%       when the dimension is large compared to the sample size. Annals of 
%       Statistics 30: 1081-1102   
%     Wang, Q and Yao J (2013). On the sphericity test with large-dimensional
%       observations. Electronic Journal of Statistics 7: 2164-2192
%
%     SEE ALSO
%     DepTest1

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

function [pval,stat] = jsn(x,varargin)

par = inputParser;
par.KeepUnmatched = true;
addRequired(par,'x',@isnumeric);
addParamValue(par,'test','john',@ischar);
parse(par,x,varargin{:});

[n,p] = size(x);

% Ledoit & Wolf (2002)
S = cov(x,0);
U = (1/p)*trace((S/((1/p)*trace(S)) - eye(p))^2);
T2 = (n-1)*p/2*U;

switch lower(par.Results.test)
   case {'john','j'}
      f = 0.5*p*(p+1) - 1;
      pval = 1 - chi2cdf(T2,f);
      stat = T2;
   case {'nagao','n'}
      f = 0.5*p*(p+1) - 1;
      % From Nagao (1973) theorem 5.1
      ap = (1/12)*(p^3+3*p^2-8*p-12-200/p);
      bp = (1/8)*(-2*p^3-5*p^2+7*p+12+420/p);
      cp = (1/4)*(p^3+2*p^2-p-2-216/p);
      dp = (1/24)*(-2*p^3-3*p^2+p+436/p);
      
      Pf = chi2cdf(T2,f);
      Pf2 = chi2cdf(T2,f+2);
      Pf4 = chi2cdf(T2,f+4);
      Pf6 = chi2cdf(T2,f+6);
      P = Pf + (1/n)*(ap*Pf6 + bp*Pf4 + cp*Pf2 + dp*Pf);
      % Truncate negative p-values
      pval = max(0,1 - P);
      stat = T2;
   case {'wang','w'}
      % Wang & Yao (2013), theorem 2.2
      N = n-1;
      if all(isreal(x))
         k = 2;
      else
         k = 1;
      end
      b = (1/(N*p)) * sum(abs(x(:)).^4) - k - 1;
      stat = N*U-p;
      pval = 1 - normcdf(stat,k+b-1,sqrt(2*k));
   otherwise
      error('Unknown method');
end

%% Various equivalent definitions of T2
% % John (1972)
% U = (trace(S^2)) / (trace(S))^2;
% T = (p*U-1)/(p-1);
% T2 = (0.5*n*p)*(p-1)*T;
% % Wang & Yao (2013)
% [~,D] = eig(S);
% l = diag(D);
% lbar = mean(l);
% T2 = ((n*p)/2) * (sum((l-lbar).^2)/p) / lbar^2;
% % Nagao (1973) 3.6
% T2 = ((p^2*n)/2) * trace((S./trace(S) - eye(p)./p)^2);
