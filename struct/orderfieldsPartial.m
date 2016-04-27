function s = orderfieldsPartial(s, fields)
    if ischar(fields)
        fields = {fields};
    end
    fields = makecol(fields);
    missing = setdiff(fieldnames(s), fields);
    s = orderfields(s, cat(1, fields, missing));
end