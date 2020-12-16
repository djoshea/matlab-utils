function v = catc(dim, c)
    if nargin == 1
        c = dim;
        dim = 1;
    end
    v = cat(dim, c{:});
end