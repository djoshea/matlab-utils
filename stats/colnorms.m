function v = colnorms(m)
    v = nansum(m.^2, 1);
end