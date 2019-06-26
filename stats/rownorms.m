function v = rownorms(m)
    v = sqrt(nansum(m.^2, 2));
end