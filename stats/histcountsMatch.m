function countByValue = histcountsMatch(in, values)

if nargin < 2
    values = unique(in);
end

assert(numel(unique(values)) == numel(values), 'Values is not unique');

[tf, indUV] = ismember(in(:), values);

countByValue = histcounts(indUV(tf), 'BinMethod', 'integers')';

end