function v =  ifelse(c, t, f)
    % ifelse(logical, valIfTrue, valIfFalse)
    
    if isscalar(t) && ~isscalar(c)
        t = repmat(t, size(c));
    end
    if isscalar(f) && ~isscalar(c)
        f = repmat(f, size(c));
    end
    
    v = t;
    v(~c) = f(~c);
end