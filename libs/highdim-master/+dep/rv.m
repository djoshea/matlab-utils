% RV                          RV coefficient of dependence
% 
%     [r,xx,yy] = rv(x,y,varargin)
%
%     INPUTS
%     x - [n x p] n samples of dimensionality p
%     y - [n x q] n samples of dimensionality q
%
%     OPTIONAL (name/value pairs)
%     type - 'mod' to calculate modified RV (Smiles et al), default='standard'
%     demean - boolean indicating to subtract mean for each var, default=TRUE
%
%     OUTPUTS
%     r  - RV coefficient
%     xx - inner product matrix of x
%     yy - inner product matrix of y 
%
%     REFERENCE
%     Smilde et al (2009). Matrix correlations for high-dimensional data: 
%       the modified RV-coefficient. Bioinformatics 25: 401-405
%
%     SEE ALSO
%     rvtest, dcorr, dcorrtest, DepTest2

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

function [r,xx,yy] = rv(x,y,varargin)

par = inputParser;
par.KeepUnmatched = true;
addRequired(par,'x',@isnumeric);
addRequired(par,'y',@isnumeric);
addParamValue(par,'type','standard',@ischar);
addParamValue(par,'demean',true,@islogical);
parse(par,x,y,varargin{:});

[n,~] = size(x);
assert(n == size(y,1),'RV requires x and y to have the same # of samples');

if par.Results.demean
   x = bsxfun(@minus,x,mean(x));
   y = bsxfun(@minus,y,mean(y));
end
xx = x*x';
yy = y*y';

switch lower(par.Results.type)
   case {'mod'}
      dind = 1:(n+1):n*n;
      xx(dind) = xx(dind)' - diag(xx);
      yy(dind) =  yy(dind)' - diag(yy);
      r = trace(xx*yy) / sqrt(trace(xx^2)*trace(yy^2));
   otherwise
      r = trace(xx*yy) / sqrt(trace(xx^2)*trace(yy^2));
end
