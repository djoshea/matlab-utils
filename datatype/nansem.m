function se = nansem(vals,dim)
    % computes the standard of the error of the mean along dimension dim
    % operates exactly like sem, except it ignores NaNs and factors this into
    % the computation of sqrt(N)
    
    % choose dim as first non singleton dimension
    if ~exist('dim', 'var')
        if numel(vals) == 1
            dim = 1;
        else
            sz = size(vals);
            dim = find(sz > 1, 1,'first');
        end
    end

    validMask = ~isnan(vals);
    n = nansum(validMask, dim); 
    s = nanstd(vals, [], dim);
    se = s ./ sqrt(n);
    se(n == 1) = NaN; 
end
