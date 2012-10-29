function v = removenan(v)
    % v = removenan(v) : removes nan from vector v
    if ~isvector(v)
        error('Must specify a vector input');
    end

    v = v(~isnan(v));
end
