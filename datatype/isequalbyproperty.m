function result = isequalbyproperty(c1, c2)

swarn = warning('off', 'MATLAB:structOnObject');

s1 = struct(c1);
s2 = struct(c2);
flds = fieldnames(s1);

for iF = 1:numel(flds)
    fld = flds{iF};
    result.(fld) = isequaln(s1.(fld), s2.(fld));
end

warning(swarn);

end