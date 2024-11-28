function n = msq(m, dim)
    if nargin < 2
        n = mean(m.^2, "all", "omitnan");
    else
        n = mean(m.^2, dim, "omitnan");
    end
end