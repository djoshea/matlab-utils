% SUMCHI2CDF                  CDF for infinite weighted sums of chi-square
% 
%     Fxval = sumchi2cdf(xval,p)
%
%     INPUTS
%     xval
%     p
%
%     OUTPUTS
%     Fxval - CDF value
%
%     REFERENCE
%     Keilson J et al (1983). Significance points for some tests of uniformity 
%       on the sphere. J Statist Comput Simul 17: 195-218.

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

function Fxval = sumchi2cdf(xval,p)

switch p
   case 3
      % Table V from Keilson et al (1983)
      if xval > 5
         Fxval = 1;
      elseif xval < 0
         Fxval = 0;
      else
         x = 0:.05:5;
         Fx = [0 0 0 0 0 0 0 0 ,...
            0.00006,0.00040,0.00170,0.00500,0.01152,0.02228,0.03792,0.05860,...
            0.08408,0.11385,0.14718,0.18331,0.22144,0.26083,0.30083,0.34085,...
            0.38043,0.41917,0.45670,0.49303,0.52776,0.56085,0.59224,0.62191,...
            0.64985,0.67609,0.70067,0.72364,0.74506,0.76501,0.78355,0.80076,...
            0.81671,0.83148,0.84514,0.85777,0.86942,0.88017,0.89008,0.89921,...
            0.90762,0.91535,0.92246,0.92899,0.93500,0.94051,0.94557,0.95021,...
            0.95446,0.95836,0.96194,0.96522,0.96822,0.97096,0.97348,0.97578,...
            0.97788,0.97981,0.98157,0.98318,0.98465,0.98600,0.98723,0.98835,...
            0.98937,0.99031,0.99116,0.99194,0.99266,0.99331,0.99390,0.99444,...
            0.99493,0.99538,0.99580,0.99617,0.99651,0.99682,0.99711,0.99737,...
            0.99760,0.99782,0.99801,0.99819,0.99835,0.99850,0.99863,0.99876,...
            0.99887,0.99897,0.99906,0.99915,0.99923];
         Fxval = interp1(x,Fx,xval,'linear');
      end
   otherwise
      error('No approximation for p requested');
end

%
% alpha = (p-1)/2;
% q = 1:10;
% a2 = (p*(2*q-1))/(8*pi*(2*q+p)) *...
%    (gamma(alpha + 0.5)*gamma(q-0.5)) ./...
%    (gamma(q+alpha+0.5)).^2;
% 
% temp = 0;
% for i = 1:numel(q)
%    vp2q = vpq(p,2*q(i));
%    temp = temp + a2(i) * chi2pdf(xval,vp2q);
% end
% 

% 
% p = 3
% syms theta
% hp = (1/sqrt(pi)) * (gamma(p/2)/(gamma((p-1)/2)*sqrt(2)))*...
%    (sin(theta).^(p-2));
% qsym = simplify(int(hp,theta,p)); % Solve integral symbolically
% pretty(qsym)
% 
% double(subs(qsym,{theta},{0:.1:pi}))
