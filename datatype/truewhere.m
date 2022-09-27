function v = truewhere(inds, n)
    if nargin < 2
        n = max(inds);
    end
    v = false(n, 1); 
    v(inds) = true;
end

