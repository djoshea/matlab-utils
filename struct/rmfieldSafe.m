function s = rmfieldSafe(s, fields)
    drop = intersect(fieldnames(s), fields);
    if ~isempty(drop)
        s = rmfield(s, drop);
    end
end