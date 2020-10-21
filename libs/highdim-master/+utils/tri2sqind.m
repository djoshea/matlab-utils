function [i,j,k] = tri2sqind( m, k )
%TRI2SQIND subscript and linear indices for upper tri portion of matrix
%
% get indices into a square matrix for a vector representing a the upper
% triangular portion of a matrix such as those returned by pdist.
%
% [i,j,k] = tri2sqind( m, k )
%  If V is a hypothetical vector representing the upper triangular portion
%  of a matrix (not including the diagonal) and
%  M is the size of a square matrix and
%  K is an optional vector of indices into V then tri2sqind returns
%  (i,j) the subscripted indices into the equivalent square matrix.
%  K is an integer index into the equivalent square matrix
%
% Example
%  X = randn(5, 20);
%  Y = pdist(X, 'euclidean');
%  [i,j,k] = tri2sqind( 5 );
%  S = squareform(Y);
%  isequal( Y(:), S(k) );
%  Z = zeros(5);
%  Z(k) = Y;
%
% Copyright 2012 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com

% Copyright (c) 2013, Michael Boedigheimer; Chris Rorden
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

max_k = m*(m-1)/2;

if ( nargin < 2 )
    k = (1:max_k)';
end;

if any( k > max_k )
    error('linstats:tri2sqind:InvalidArgument', 'ind2subl:Out of range subscript');
end;


i = floor(m+1/2-sqrt(m^2-m+1/4-2.*(k-1)));
j = k - (i-1).*(m-i/2)+i;
k = sub2ind( [m m], i, j );
%end tri2sqind()