function n = nn(in, dims)

    if nargin < 2
        if isstring(in)
            n = 0;
            return;
        end
        
        if isobject(in)
            in = struct(in);
        end
        
        if isstruct(in)
            flds = fieldnames(in);
            n = 0;
            for iF = 1:numel(flds)
                n = n + nn(in.(flds{iF}));
            end
        elseif iscell(in)
            n = 0;
            for iC = 1:numel(in)
                n = n + nn(in{iC});
            end
        else
            n = nnz(isnan(in));
        end
    else
        n = sum(isnan(in), dims);
    end

end