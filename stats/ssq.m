function n = ssq(m, dim)
    if nargin < 2
        n = nansum(m(:).^2);
    else
        n = nansum(m.^2, dim);
    end
end