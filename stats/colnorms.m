function v = colnorms(m)
    v = sqrt(nansum(m.^2, 1));
end