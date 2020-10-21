% SIGEST                      Estimate bandwidth of Gaussian kernel
% 
%     sigma = sigest(X,varargin)
% 
%     INPUTS
%     X     - [n x p] m samples of dimensionality p
% 
%     OPTIONAL
%     sigest - string indicating method for estimating sigma, 
%              'median' - Median heuristic, Gretton et al. 2012
%              'adapt'  - 
%     frac   - scalar (0,1] indicating fraction of data to use for sigest
% 
%     OUTPUTS
%     sigma - standard deviation of Gaussian kernel
% 
%     SEE ALSO
%     rbf

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

function sigma = sigest(X,varargin)

par = inputParser;
par.KeepUnmatched = true;
addRequired(par,'X',@isnumeric);
addParamValue(par,'frac',[],@(x) isscalar(x) && (x>0) && (x<=1));
addParamValue(par,'sigest','median',@ischar);
parse(par,X,varargin{:});

[n,p] = size(X);
if isempty(par.Results.frac)
   ind = ceil(n*0.1);
   X = X(1:min(n,ind),:);
elseif par.Results.frac ~= 1
   ind = ceil(n*par.Results.frac);
   X = X(1:min(n,ind),:);
end

switch lower(par.Results.sigest)
   case {'median'}
      % Median heuristic, Gretton et al. 2012
      sigma = sqrt(0.5*median(pdist(X).^2));
   case {'adapt'}
      % TODO
   otherwise
      error('Unknown sigma estimator');
end