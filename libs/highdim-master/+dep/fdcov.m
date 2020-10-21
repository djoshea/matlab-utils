% FDCOV                       Fast distance covariance
% 
%     d = fdcov(x,y)
%
%     Estimate (unbiased) distance covariance using Huo & Szekely algorithm,
%     which has O(n log n) complexity and O(n) storage compared to 
%     O(n^2) complexity and O(n^2) storage of the naive estimator.
%     Valid for univariate and real inputs.
%
%     INPUTS
%     x - [n x 1] samples
%     y - [n x 1] samples 
%
%     OUTPUTS
%     d - distance covariance between x,y
%
%     REFERENCE
%     Huo & Szekely (2016). Fast Computing for Distance Covariance,
%       Technometrics, 58, 435?447. DOI:10.1080/00401706.2015.1054435
%
%     SEE ALSO
%     fdcorr, rpdcov

%     Modified from supplementary materials of Huo & Szekely
%     $ Copyright (C) 2014 Xiaoming Huo $

function d = fdcov(x,y)

n = length(x);
assert(isvector(x) && isvector(y),'FDCOV requires x & y to be univariate');
assert(n == numel(y),'FDCOV requires x & y to be the same length');

if isrow(x)
   x = x';
end

if isrow(y)
   y = y';
end

temp = (1:n)';
[vx,Ix0] = sort(x); Ix(Ix0) = temp; Ix = Ix'; 
[vy,Iy0] = sort(y); Iy(Iy0) = temp; Iy = Iy'; 
sx = cumsum(vx); 
sy = cumsum(vy); 
alphax = Ix - 1; 
alphay = Iy - 1; 
betax = sx(Ix) - vx(Ix); 
betay = sy(Iy) - vy(Iy); 
xdot = sum(x); 
ydot = sum(y); 

aidot = xdot + (2*alphax-n).*x - 2*betax; 
bidot = ydot + (2*alphay-n).*y - 2*betay; 
Sab = sum(aidot.*bidot); 

adotdot = 2*sum(alphax.*x) - 2*sum(betax); 
bdotdot = 2*sum(alphay.*y) - 2*sum(betay); 

gamma_1  = partialSum2D(x,y,ones(n,1));
gamma_x  = partialSum2D(x,y,x);
gamma_y  = partialSum2D(x,y,y);
gamma_xy = partialSum2D(x,y,x.*y);

aijbij = sum(x.*y.*gamma_1 + gamma_xy - x.*gamma_y - y.*gamma_x); 
d = aijbij/n/(n-3) - 2*Sab/n/(n-2)/(n-3) + adotdot*bdotdot/n/(n-1)/(n-2)/(n-3); 

function gamma = partialSum2D(x,y,c)

n = length(x);
temp = (1:n)';

[~,Ix0] = sort(x);
Ix(Ix0) = temp; % Ix = order stat
 
y = y(Ix0); 
c = c(Ix0);     % so x is at increasing order
[~,Iy0] = sort(y);
Iy(Iy0) = temp;
y = Iy';        % y is a perm of {1,...,n}

sy = cumsum(c(Iy0)) - c(Iy0);
sx = cumsum(c) - c;
cdot = sum(c);

gamma1 = utils.mexDyadUpdate(y,c);

gamma = cdot - c - 2*sy(Iy) - 2*sx + 4*gamma1;
gamma = gamma(Ix);