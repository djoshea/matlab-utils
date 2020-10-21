function M = putdiag(M,x)

[m,n] = size(M);

assert((numel(x)==1)||(numel(x)==min(m,n)),'Wrong # of elements for diagonal');

M(1:(m+1):min(m*m,m*n)) = x;
