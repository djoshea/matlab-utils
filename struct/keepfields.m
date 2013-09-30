function s = keepfields(s, fields)
    s = rmfield(s, setdiff(fieldnames(s), fields));
end