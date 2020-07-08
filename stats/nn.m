function n = nn(in, dims)

    if nargin < 2
        if isstruct(in)
            flds = fieldnames(in);
            n = 0;
            for iF = 1:numel(flds)
                n = n + nn(in.(flds{iF}));
            end
        else
            n = nnz(isnan(in));
        end
    else
        n = sum(isnan(in), dims);
    end

end