function n = nz(in, dims)

    if nargin < 2
        if isstruct(in)
            flds = fieldnames(in);
            n = 0;
            for iF = 1:numel(flds)
                n = n + nz(in.(flds{iF}));
            end
        else
            n = nnz(in == 0);
        end
    else
        n = sum(in == 0, dims);
    end

end