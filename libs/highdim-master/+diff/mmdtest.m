% MMDTEST                     Two-sample maximal mean discrepancy test
% 
%     [pval,stat,boot] = mmdtest(x,y,varargin)
%
%     Given a sample X1,...,Xm from a p-dimensional multivariate distribution,
%     and a sample Y1,...,Xn from a q-dimensional multivariate distribution,
%     test the hypothesis:
%
%     H0 : X and Y are drawn from the same distribution
%
%     INPUTS
%     x - [m x p] m samples of dimensionality p
%     y - [n x p] n samples of dimensionality p
%
%     OPTIONAL
%     nboot - # bootstrap samples (default = 1000)
%     sigma - gaussian bandwidth (default = median heuristic)
%     biased - boolean indicated biased estimator (default = false)
%
%     OUTPUTS
%     pval - p-value
%     stat - maximal mean discrepancy
%     boot - bootstrap samples
%
%     REFERENCE
%     Gretton et al (2012). A kernel two-sample test. 
%       Journal of Machine Learning Research 13: 723-773
%
%     SEE ALSO
%     mmd, DepTest2

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

function [pval,stat,boot] = mmdtest(x,y,varargin)

par = inputParser;
par.KeepUnmatched = true;
addRequired(par,'x',@isnumeric);
addRequired(par,'y',@isnumeric);
addParamValue(par,'nboot',1000,@(x) isscalar(x)&&isnumeric(x));
parse(par,x,y,varargin{:});

[m,p] = size(x);
[n,q] = size(y);
if p ~= q
   error('x and y must have same dimensionality (# of columns)');
end

[stat,K,L,KL,sigma,biased] = diff.mmd(x,y,par.Unmatched);

nboot = par.Results.nboot;
boot = zeros(nboot,1);
% aggregated kernel matrix
M = [K KL; KL' L];
for i = 1:nboot
   ind = randperm(n+m);
   K = M(ind(1:m),ind(1:m));
   L = M(ind(m+1:end),ind(m+1:end));
   KL = M(ind(1:n),ind(m+1:end));
   boot(i) = diff.mmd_(K,L,KL,m,n,biased);
end

pval = sum(boot>=stat)./nboot;
