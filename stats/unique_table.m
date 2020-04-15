function tbl = unqiue_table(vals)
% generates a table indicating the count of each unique element in vals

[Value, ~, ic] = unique(vals(:));

Count = arrayfun(@(i) nnz(ic == i), (1:numel(Value))');

tbl = table(Value, Count);
tbl = sortrows(tbl, 'Count', 'descend');

end