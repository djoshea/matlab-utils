function v = removenan(v)
    % v = removenan(v) : removes nan from vector v
    if ~isempty(v) && ~isvector(v)
        error('Must specify a vector input');
    end

    if iscell(v)
        nanMask = cellfun(@isnan, v);
    else
        nanMask = isnan(v);
    end
    v = v(~nanMask);
end
