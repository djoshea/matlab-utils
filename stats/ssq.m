function n = ssq(m, dim)
    if nargin < 2
        n = sum(m.^2, "all", "omitnan");
    else
        n = sum(m.^2, dim, "omitnan");
    end
end