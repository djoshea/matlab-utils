% CPCA                        Common principal component analysis
%
%     [Q,D,iter] = cpca(S,n,varargin)
%
%     INPUTS
%     S - covariance matrices, [n x n x groups] matrix or cell array
%     n - sample size for each S_i, vector or cell array
%
%     OPTIONAL
%     k - number of common components to return (default = all)
%     maxit - maximum number of iterations (default = 100)
%     tol - stopping criteria (default = 1e-6)
%
%     OUTPUTS
%
%     REFERENCE
%     Trendafilov (2010). Stepwise estimation of common principal
%       components. Computational Statistics & Data Analysis 54: 3446-3457
%
%     Based on Matlab code provided by Dr. Trendafilov, modified to include
%     stopping criterion.

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

function [Q,D,iter] = cpca(S,n,varargin)

par = inputParser;
par.KeepUnmatched = true;
addRequired(par,'S',@(x) isnumeric(x)||iscell(x));
addRequired(par,'n',@(x) isnumeric(x)||iscell(x));
addParamValue(par,'k',[],@isnumeric);
addParamValue(par,'maxit',100,@(x) isnumeric(x) && isscalar(x));
addParamValue(par,'tol',1e-6,@isnumeric);
parse(par,S,n,varargin{:});

if iscell(S)
   S = cat(3,S{:});
end

if iscell(n)
   n = cat(2,n{:});
end

p = size(S,1);
nS = size(S,3);
if nS ~= numel(n)
   error('n should indicate the # of samples for each group');
end

if isempty(par.Results.k)
   k = p;
elseif par.Results.k <= p
   k = par.Results.k;
else
   error('k must be less than dimensionality');
end

nf = n./sum(n);
D = zeros(k,nS);
Q = zeros(p,k);
Qw = eye(p);
s = zeros(p);
for j = 1:nS
   s = s + nf(j)*S(:,:,j);
end

[q0,d0] = eig(s);
if d0(1,1) < d0(p,p)
   q0 = q0(:,p:-1:1);
end

iter = zeros(1,k);
for i = 1:k
   q = q0(:,i);
   d = zeros(1,nS);
   for j = 1:nS
      d(j) = q'*S(:,:,j)*q;
   end

   crit = 1;
   while (iter(i) < par.Results.maxit) && (crit > par.Results.tol)
      s = zeros(p);
      for j = 1:nS
         s = s + n(j)*S(:,:,j)/d(j);
      end
      
      w = s*q;
      if i ~= 1
         w = Qw*w;
      end
      q = w/((w'*w)^.5);
      
      for j = 1:nS
         d(j) = q'*S(:,:,j)*q;
      end
           
      if iter(i) > 1
         crit = old - norm(d);
      end
      old = norm(d);
      iter(i) = iter(i) + 1;
   end
   
   D(i,:) = d;
   Q(:,i) = q;
   Qw = Qw - q*q';
end
