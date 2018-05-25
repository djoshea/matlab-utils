function [skeep, srem] = keepfields(s, fields)
    skeep = rmfield(s, setdiff(fieldnames(s), fields));
    skeep = orderfields(skeep, intersect(fields, fieldnames(skeep), 'stable'));
    
    if nargout >= 2
        srem = rmfield(s, intersect(fieldnames(s), fields));
    end
end