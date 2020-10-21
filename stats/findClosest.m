function [val, ind] = findClosest(vec, values)
    vec = makecol(vec);
    values = makecol(values);
    [~, ind] = min(abs(vec' - values), [], 2);
    val = vec(ind);
end
