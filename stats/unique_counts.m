function [uv, counts] = unique_counts(v)
    v = makecol(v);
    [uv, ~, iv] = unique(v);
    edges = 1:numel(uv)+1;
    counts = makecol(histcounts(iv, edges));
end