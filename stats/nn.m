function n = nn(in, dims)

    if nargin < 2
        n = nnz(isnan(in));
    else
        n = sum(isnan(in), dims);
    end

end