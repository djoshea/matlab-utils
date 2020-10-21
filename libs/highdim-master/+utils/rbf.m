% RBF                         Kernel matrix using Gaussian radial basis
% 
%     [k,sigma] = rbf(x,y,varargin)
% 
%     INPUTS
%     x     - [m x p] m samples of dimensionality p
%     y     - [n x p] n samples of dimensionality p
%             OR [], empty
% 
%     OPTIONAL
%     sigma  - scalar, standard deviation of Gaussian kernel, default = []
%     Only valid when sigma = []
%     sigest - string indicating method for estimating sigma, 
%              'median' - Median heuristic, Gretton et al. 2012
%              'adapt'  - 
%     frac   - scalar (0,1] indicating fraction of data to use for sigest
% 
%     Additional name/value pairs are passed through to function for 
%     estimating the kernel when using an approximation method.
% 
%     OUTPUTS
%     k     - kernel matrix
%     sigma - standard deviation of Gaussian kernel
% 
%     SEE ALSO
%     sigest

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

function [k,sigma] = rbf(x,y,varargin)

par = inputParser;
par.KeepUnmatched = true;
addRequired(par,'x',@isnumeric);
addRequired(par,'y',@isnumeric);
addParamValue(par,'sigma',[],@(x) isnumeric(x) && isscalar(x));
parse(par,x,y,varargin{:});

if isempty(par.Results.sigma)
   % Set sigma based on first input
   sigma = utils.sigest(x,par.Unmatched);
else
   sigma = par.Results.sigma;
end

k = exp(-utils.sqdist(x,y)/(2*sigma^2));