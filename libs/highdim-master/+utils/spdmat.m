% Generate a dense n x n symmetric, positive definite matrix
function A = spdmat(n)

A = rand(n,n);
A = A+A';
% since A(i,j) < 1 by construction and a symmetric diagonally dominant matrix
%   is symmetric positive definite, which can be ensured by adding nI
A = A + n*eye(n);
