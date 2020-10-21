% PERMMOMENTS                 Exact moments of permutation distribution
% 
%     [mu,sigma2,skew] = permMoments(A1,A2,approx)
%
%     Returns the first three moments of the permutation distribution of 
%     T = trace(A1*A2). Exact expressions have been obtained by Kazi-Aoual
%     et al (1995). The specific formulation used here comes from Bilodeau
%     and Guetsop Nangue (2017).
%     
%     INPUTS
%     A1 - [n x n] matrix
%     A2 - [n x n] matrix
%
%     OPTIONAL
%     approx - scalar integer >= 0, positive integers determine rank of 
%              approximate multiplication A1*A2, default = 0 (exact)
%
%     REFERENCE
%     Bilodeau & Guetsop Nangue (2017). Approximations to permutation tests 
%       of independence between two random vectors. 
%       Computational Statistics & Data Analysis, submitted.
%     Kazi-Aoual et al (1995). Refined approximations to permutation tests 
%       for multivariate inference. Computational Statistics & Data Analysis.
%       20: 643-656

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

function [mu,sigma2,skew] = permMoments(A1,A2,approx)

if nargin < 3
   approx = 0;
end

assert(all(size(A1)==size(A2)),'A1 and A2 must have the same size.');
[m,n] = size(A1);
assert(m==n,'A1 and A2 must be square.');

[T(1),T2(1),S2(1),T3(1),S3(1),U(1),R(1),B(1)] = useful(A1,approx);
[T(2),T2(2),S2(2),T3(2),S3(2),U(2),R(2),B(2)] = useful(A2,approx);

% First moment
m1 = prod(T)/n + prod(-T)/(n*(n-1));

% Second moment
m2 = prod(S2)/n...
   + ( prod(T.^2-S2) + 2*prod(T2-S2) + 4*prod(-S2) ) / (n*(n-1))...
   + ( 4*prod(2*S2-T2) + 2*prod(2*S2-T.^2) ) / (n*(n-1)*(n-2))...
   + prod(2*T2-6*S2+T.^2) / (n*(n-1)*(n-2)*(n-3));

% Third moment
SP1 = prod(S3)/n;
SP2 = ( 4*prod(-S3+U) + 3*prod(T.*S2-S3) + 6*prod(-S3)...
   + 12*prod(-S3+R) + 6*prod(-S3+B) ) / (n*(n-1));
SP3 = ( 3*prod(-T.*S2+2*S3) + prod(T.^3-3*T.*S2+2*S3)...
   + 12*prod(-T.*S2+2*S3-B) + 12*prod(2*S3-R) + 24*prod(2*S3-R-B)...
   + 6*prod(T.*(T2-S2)+2*S3-2*R) + 24*prod(2*S3-U-R)...
   + 8*prod(T3+2*S3-3*R) ) / (n*(n-1)*(n-2));
SP4 = ( 12*prod(T.*S2-6*S3+2*R+2*B) + 6*prod(T.*(-T2+S2)-6*S3+2*U+4*R)...
   + 3*prod(-T.^3+5*T.*S2-6*S3+2*B) + 12*prod(T.*(-T2+2*S2)-6*S3+3*R+2*B)...
   + 8*prod(-6*S3+2*U+3*R) + 24*prod(-T3-6*S3+U+5*R+B) ) / (n*(n-1)*(n-2)*(n-3));
SP5 = ( 3*prod(T.^3+2*T.*(T2-5*S2) + 24*S3-8*R-8*B)...
   + 12*prod(T.*(T2-2*S2) + 2*T3+24*S3-4*U-16*R-4*B) ) / (n*(n-1)*(n-2)*(n-3)*(n-4));
SP6 = prod(-T.^3-6*T.*(T2-3*S2)-8*T3-120*S3+16*U+72*R+24*B)...
   / (n*(n-1)*(n-2)*(n-3)*(n-4)*(n-5));
m3 = SP1 + SP2 + SP3 + SP4 + SP5 + SP6;

mu = m1;
sigma2 = m2 - m1^2;
skew = (m3 - 3*sigma2*m1 - m1^3) / (sigma2^(3/2));

function [T,T2,S2,T3,S3,U,R,B] = useful(A,approx)
T = trace(A);
if approx
   AA = utils.approxmtimes(A,A,approx);
else
   AA = A*A;
end
T2 = sum(sum(A.^2)); 
S2 = sum(diag(A.^2));
T3 = sum(sum(AA.*A));
S3 = sum(diag(A).^3);
U = sum(sum(A.^2.*A));
R = diag(A)'*diag(AA);
B = diag(A)'*A*diag(A);
