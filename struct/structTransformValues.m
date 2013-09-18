function S = structTransformValues(fn, S)
% S = structTransformValues(fn, S)
% call function fn on each value of S and substitute returned value in place

vals = cellfun(fn, struct2cell(S), 'UniformOutput', false);
S = cell2struct(vals, fieldnames(S), 1);

end
