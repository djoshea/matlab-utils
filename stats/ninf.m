function n = ninf(in, dims)

    if nargin < 2
        if isstruct(in)
            flds = fieldnames(in);
            n = 0;
            for iF = 1:numel(flds)
                n = n + ninf(in.(flds{iF}));
            end
        else
            n = nnz(isinf(in));
        end
    else
        n = sum(isinf(in), dims);
    end

end