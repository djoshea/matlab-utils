function [tbl, fldsA_only, fldsB_only] = struct_diff_fields(A, B)

fldsA = string(fieldnames(A));
fldsB = string(fieldnames(B));

fldsCommon = intersect(fldsA, fldsB);
fldsA_only = setdiff(fldsA, fldsB);
fldsB_only = setdiff(fldsB, fldsA);

mask = false(numel(fldsCommon), 1);
[val_A, val_B] = cellvec(numel(fldsCommon));
for iF = 1:numel(fldsCommon)
    fld = fldsCommon{iF};
    mask(iF) = ~isequaln(A.(fld), B.(fld));
    val_A{iF} = A.(fld);
    val_B{iF} = B.(fld);
end

field = fldsCommon(mask);
val_A = val_A(mask);
val_B = val_B(mask);

tbl = table(field, val_A, val_B);

end