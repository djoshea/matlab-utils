% APPROXMTIMES                Approximate matrix multiplication
% 
%     AB = approxmtimes(A,B,c,method,uni)
%
%     Given matrices A [m x n] and B [n x p], approximates the product A*B
%     with a sum of rank-one matrices by selecting c columns (rows) of A (B)
%      
%                A*B \approx \sum_{c in C} A(:,c)*B(c,:)
%
%     Two algorithms are available, one using randomized selection (Drineas
%     et al) and the other using greedy deterministic selection (Belabbas &
%     Wolfe).
%     
%     Complexity:
%     sampling - O(c(m+n+p))
%     greedy   - O(m(n+c^2) + c^3)
%
%     INPUTS
%     A - [m x n] matrix
%     B - [n x p] matrix
%     c - scalar < n, approximant rank
%
%     OPTIONAL
%     method - string indicating approximation algorithm (default = 'sampling')
%            'sampling' - monte-carlo column-row selections using either
%                         uniform probabilities or probabilities that 
%                         minimize expected normwise absolute error
%            'greedy'   - deterministic approximation to optimal subset
%     uni    - boolean indicating uniform sampling (default = false)
%              only applies for method = 'random'
%
%     OUTPUTS
%     AB - approximation of A*B
%
%     EXAMPLE
%     import utils.* 
%     rng(1);
%     m = 3000;
%     n = m;
%     A = [randn(m/2,n) ; rand(m/2,n)*20];
%     B = [rand(m/2,n)*20 ; randn(m/2,n)];
% 
%     tic; AB = A*B; toc
%     tic; AB1 = approxmtimes(A,B,25); toc
%     tic; AB2 = approxmtimes(A,B,25,'greedy'); toc
% 
%     norm(AB1-AB,'fro')^2/norm(AB,'fro')^2
%     norm(AB2-AB,'fro')^2/norm(AB,'fro')^2
%
%     REFERENCE
%     Drineas et al. (2006). Fast Monte Carlo algorithms for matrices I: 
%       Approximating matrix multiplication. SIAM Journal on Computing, 
%       36, 132-157
%     Belabbas & Wolfe (2008). On sparse representations of linear operators 
%       and the approximation of matrix products. In Information Sciences 
%       and Systems. CISS 2008, 258-263

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

% TODO
%  o B = A
%  o B = A'
%  o streaming (one-pass for uni with n known, two-pass for other cases)
%  o nargout == 2 should return C & R for all algs, AB \approx C*R
%  o faster randsample

function AB = approxmtimes(A,B,c,method,uni)

if nargin < 5
   uni = false;
end

if nargin < 4
   method = 'sampling';
end

[m,n] = size(A);
[n2,p] = size(B);
c = fix(c);

assert(n==n2,'Inner matrix dimensions must agree.');
assert(c>=1,'c must be >= 1.');

switch lower(method)
   case {'greedy'}
      A2 = A.^2;
      An = sum(A2)';
      B2 = B.^2;
      Bn = sum(B2,2);
      [~,J] = sort(An.*Bn,'descend');
      J = J(1:c);
      
      Q =  (A(:,J)'*A(:,J)) .* (B(J,:)*B(J,:)');
      r = sum( (A'*A(:,J)) .* (B*B(J,:)') )';
      w = Q\r;
      
      AB = A(:,J)*diag(w)*B(J,:);
   case {'sampling'}
      if uni
         p_k = repmat(1/n,n,1);
      else
         % Probabilities that minimize expected normwise absolute error
         A2 = A.^2;
         An = sqrt(sum(A2))';
         B2 = B.^2;
         Bn = sqrt(sum(B2,2));
         
         p_k = An.*Bn;
         p_k = p_k/sum(p_k);
      end
      
      J = randsample(1:n,c,true,p_k);
      
      cp = sqrt(c*p_k(J));
      C = bsxfun(@rdivide,A(:,J),cp');
      R = bsxfun(@rdivide,B(J,:),cp);
      
      AB = C*R;
   otherwise
      error('Unrecognized method for approximate matrix multiplication');
end