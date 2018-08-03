function idx = argmax(vec, n)

if nargin < 2
    [~, idx] = nanmax(vec);
else
    [~, idx] = sort(vec, 'descend', 'MissingPlacement', 'last');
    idx = idx(1:n);
end

end