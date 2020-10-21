%function [X,mu,invMat] = whiten(X,epsilon)
%
% ZCA whitening of a data matrix (make the covariance matrix identity)
%
% WARNING
% This form of whitening performs poorly if the number of dimensions are
% much greater than the number of instances
%
% INPUT
% X: rows are the instances, columns are the features
% epsilon: small number to compensate for nearly 0 eigenvalue [DEFAULT =
% 0.0001]
%
% OUTPUT
% Xwh: whitened data, rows are instances, columns are features
% whMat: the whitening matrix

% Copyright (c) 2012, Colorado Reed 
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
% * Redistributions of source code must retain the above copyright 
% notice, this list of conditions and the following disclaimer. 
% * Redistributions in binary form must reproduce the above copyright 
% notice, this list of conditions and the following disclaimer in 
% the documentation and/or other materials provided with the distribution

function [X,whMat] = whiten(X,epsilon)

if nargin < 2
   epsilon = 0.0001;
end

mu = mean(X); 
X = bsxfun(@minus, X, mu);
A = X'*X;
[V,D,~] = svd(A);
whMat = sqrt(size(X,1)-1)*V*sqrtm(inv(D + eye(size(D))*epsilon))*V';
X = X*whMat;
