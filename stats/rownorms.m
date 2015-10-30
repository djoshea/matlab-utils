function v = rownorms(m)
    v = nansum(m.^2, 2);
end