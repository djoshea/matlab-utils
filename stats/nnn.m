function n = nnn(in, dims)
% number of non-nan

    if nargin < 2
        if isstruct(in)
            flds = fieldnames(in);
            n = 0;
            for iF = 1:numel(flds)
                n = n + nnn(in.(flds{iF}));
            end
        elseif iscell(in)
            n = 0;
            for iC = 1:numel(in)
                n = n + nnn(in{iC});
            end
        else
            n = nnz(~isnan(in));
        end
    else
        n = sum(~isnan(in), dims);
    end

end