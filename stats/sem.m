function se = sem(vals,dim)
    % choose dim as first non singleton dimension
    if ~exist('dim', 'var')
        if isscalar(vals)
            dim = 1;
        else
            sz = size(vals);
            dim = find(sz > 1, 1, 'first');
        end
    end
    
    if isempty(vals)
        se = NaN;
        return;
    end

    n = size(vals, dim); 
    s = std(vals, [], dim, 'omitmissing');
    se = s / sqrt(n);
    
    if n == 1
        se(:) = NaN;
    end
end
