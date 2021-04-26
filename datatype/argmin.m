function idx = argmin(vec)

[~, idx] = min(vec, [], 'all', 'omitnan', 'linear');

end