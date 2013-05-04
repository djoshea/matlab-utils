function s = keepfields(s, fields)
    s = rmfields(s, setdiff(fieldnames(s), fields));
end