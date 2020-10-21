% MMD                         Maximal mean discrepancy
% 
%     [m,sigma] = mmd(x,y,varargin)
%
%     INPUTS
%     x - [m x p] m samples of dimensionality p
%     y - [n x p] n samples of dimensionality p
%
%     OPTIONAL (name/value pairs)
%     sigma - gaussian bandwidth, default = median heuristic
%     biased - boolean indicated biased estimator (default=false)
%
%     OUTPUTS
%     stat - maximal mean discrepancy
%
%     REFERENCE
%     Gretton et al (2012). A kernel two-sample test. 
%       Journal of Machine Learning Research 13: 723-773
%
%     SEE ALSO
%     mmdtest

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

function [stat,K,L,KL,sigma,biased] = mmd(x,y,varargin)

par = inputParser;
par.KeepUnmatched = true;
addRequired(par,'x',@isnumeric);
addRequired(par,'y',@isnumeric);
addParamValue(par,'sigma',[],@isnumeric);
addParamValue(par,'biased',false,@(x) isnumeric(x) || islogical(x));
parse(par,x,y,varargin{:});

[m,p] = size(x);
[n,q] = size(y);
if p ~= q
   error('x and y must have same dimensionality (# of columns)');
end

if isempty(par.Results.sigma)
   % Median heuristic, Gretton et al. 2012
   sigma = sqrt(0.5*median(pdist([x;y]).^2));
else
   sigma = par.Results.sigma;
end

K = utils.rbf(sigma,x);
L = utils.rbf(sigma,y);
KL = utils.rbf(sigma,x,y);
K = utils.zerodiag(K);
L = utils.zerodiag(L);

biased = par.Results.biased;
stat = diff.mmd_(K,L,KL,m,n,biased);
