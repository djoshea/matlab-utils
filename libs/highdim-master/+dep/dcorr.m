% DCORR                       Distance correlation
% 
%     r = dcorr(x,y,varargin)
%
%     INPUTS
%     x - [n x p] n samples of dimensionality p
%     y - [n x q] n samples of dimensionality q
%
%     OPTIONAL (as name/value pairs, order irrelevant)
%     unbiased - true indicates bias-corrected estimate (default=false)
%     dist     - true indicates x & y are distance matrices (default=false)
%     doublecenter - true indicates x & y are double-centered distance 
%                matrices (default=false)
%
%     OUTPUTS
%     r - distance correlation between x,y
%
%     REFERENCE
%     Szekely et al (2007). Measuring and testing independence by correlation 
%       of distances. Ann Statist 35: 2769-2794
%     Szekely & Rizzo (2013). The distance correlation t-test of independence 
%       in high dimension. J Multiv Analysis 117: 193-213
%
%     SEE ALSO
%     dcorrtest, dcov

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

function r = dcorr(x,y,varargin)

par = inputParser;
par.KeepUnmatched = true;
addRequired(par,'x',@isnumeric);
addRequired(par,'y',@isnumeric);
parse(par,x,y,varargin{:});

[d,dvx,dvy] = dep.dcov(x,y,par.Unmatched);
if (dvx*dvy) > eps
   r = d/sqrt(dvx*dvy);
else
   r = 0;
end
