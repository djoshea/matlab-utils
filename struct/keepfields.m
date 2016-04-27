function s = keepfields(s, fields)
    s = rmfield(s, setdiff(fieldnames(s), fields));
    s = orderfields(s, intersect(fields, fieldnames(s), 'stable'));
end