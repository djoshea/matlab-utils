function b = squeezedim(a, dim)
%SQUEEZEDIM Remove specific dimension if singleton
%   B = SQUEEZE(A, DIM) returns an array B with the same elements as
%   A but with dimension DIM removed if singleton.  A singleton
%   is a dimension such that size(A,dim)==1.
%
%   See also SQUEEZE

    if nargin < 2
        error('Usage: squeezedim(a, dim)');
    end

    siz = size(a);
    if ndims(a) < max(dim)
        b = a;
    else
        dim = dim(siz(dim) == 1);
        siz(dim) = []; % Remove singleton dimensions.
        siz = [siz ones(1,2-length(siz))]; % Make sure siz is at least 2-D
        b = reshape(a,siz);
    end

end
