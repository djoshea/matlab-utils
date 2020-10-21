function [R U V] = poldecomp(F)
%POLDECOMP  Performs the polar decomposition of a regular square matrix.
%   [R U V] = POLDECOMP(F) factorizes a non-singular square matrix F such
%   that F=R*U and F=V*R, where
%   U and V are symmetric, positive definite matrices and
%   R is a rotational matrix
%
%   See also EIG, DIAG, REPMAT

% Copyright (c) 2014, Zoltan Csati
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

% This kind of decomposition is often used in continuum mechanics so it is
% convenient to comment the code that way. From now, we use the matrix 
% formalism of tensors. C is the right Cauchy-Green deformation tensor, 
% F is the deformation tensor, lambda is the stretch.

% Check input
[m n] = size(F);
if m ~= n
    error('Matrix must be square.');
end

C = F'*F;
[Q0 lambdasquare] = eig(C);
lambda = sqrt(diag((lambdasquare))); % extract the components
% Uinv is the inverse of U and is constructed with the help of Q0. Uinv is
% produced in the same base as F not in the base of its eigenvectors.
Uinv = repmat(1./lambda',size(F,1),1).*Q0*Q0';
% Using the definition, R, U and V can now be calculated
R = F*Uinv;
U = R'*F;
V = F*R';