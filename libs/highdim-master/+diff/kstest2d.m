% kstest2d                   Two-dimensional, 2-sample Kolmorogov-Smirnov test
% 
%     [p,D] = kstest2d(s1,s2);
%
%     Compare two, 2-dimensional distributions using Fasano & Franceschini's
%     generalization of the KS-test.
%
%     The analytic distribution of the statistic is unknown, and p-values
%     are estimated using an approximation (Press et al., 1992) to FF's Monte
%     Carlo simulations.
%
%     INPUTS
%     s1 - [n1 x 2] matrix
%     s2 - [n2 x 2] matrix
%
%     OUTPUTS
%     p  - approximate p-value
%     D  - K-S statistic
%
%     REFERENCE
%     Fasano, G, Franceschini, A (1987) A multidimensional version of the
%       Kolmorogov-Smirnov test. Mon Not R astr Soc 225: 155-170
%     Press et al (1992). Numerical Recipes in C, section 14.7
%
%     SEE ALSO
%     minentest, hotell2, DepTest2

%     $ Copyright (C) 2014 Brian Lau http://www.subcortex.net/ $
%     The full license and most recent version of the code can be found on GitHub:
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
%
%     REVISION HISTORY:
%     brian 03.14.06 written
%     brian 08.23.11 added flag to assign point to quadrant that maximizes D
%                    http://www.nr.com/forum/showthread.php?t=576

function [p,D] = kstest2d(s1,s2)

assign_point = false; % Set true to assign center point to maximizing quadrant
                      % Leave this false if you want FF's original procedure

[n1,m1] = size(s1);
[n2,m2] = size(s2);

if ~all([m1,m2]==2)
   error('# of columns in X and Y must equal 2');
end

D = zeros(n1+n2,4);
count = 0;
for i = 1:n1
   count = count + 1;
   [a1,b1,c1,d1] = quadcnt(s1(i,1),s1(i,2),s1,n1-1);
   [a2,b2,c2,d2] = quadcnt(s1(i,1),s1(i,2),s2,n2);

   temp = abs([a1-a2 , b1-b2 , c1-c2 , d1-d2]);
   if assign_point
      % Assign point to quadrant where it maximizes difference
      ind = find(max(temp));
      if length(ind) >= 1
         ind = ind(1); % take first maximum
         temp(ind) = temp(ind) + 1/length(s1);
      end
   end
   D(count,:) = temp;
end
for i = 1:n2
   count = count + 1;
   [a1,b1,c1,d1] = quadcnt(s2(i,1),s2(i,2),s1,n1);
   [a2,b2,c2,d2] = quadcnt(s2(i,1),s2(i,2),s2,n2-1);
 
   temp = abs([a1-a2 , b1-b2 , c1-c2 , d1-d2]);
   if assign_point
      % Assign point to quadrant where it maximizes difference
      ind = find(max(temp));
      if length(ind) >= 1
         ind = ind(1); % take first maximum
         temp(ind) = temp(ind) + 1/length(s2);
      end
   end
   D(count,:) = temp;
end

D = max(max(D));

% Average correlation coefficients
r1 = corrcoef(s1); r1 = r1(1,2);
r2 = corrcoef(s2); r2 = r2(1,2);
rr = 0.5*(r1*r1 + r2*r2);

p = probks(n1,n2,D,rr);

%----- Count fractions of points in s in quadrants defined around point (x,y).
% s is a nx2 matrix
%
% a|b
%-----
% c|d
%
% Currently, the point x,y is not counted in any fraction
function [a,b,c,d] = quadcnt(x,y,s,d)

slx = s(:,1)<x;
sgx = s(:,1)>x;
sly = s(:,2)<y;
sgy = s(:,2)>y;

inda = slx & sgy;
indb = sgx & sgy;
indc = slx & sly;
indd = sgx & sly;

a = sum(inda)/d;
b = sum(indb)/d;
c = sum(indc)/d;
d = sum(indd)/d;

%----- Asymptotic Q-function to approximate the 2-sided P-value
function p = probks(n1,n2,D,rr)

% Numerical Recipes in C, section 14.7
N = (n1*n2)/(n1+n2);
lambda = (sqrt(N)*D) / (1 + sqrt(1 - rr)*(.25 - .75/sqrt(N)));

j = (1:101)';
p = 2 * sum((-1).^(j-1).*exp(-2*lambda*lambda*j.^2));
p = min(max(p,0),1);


