function structArray = structOfArraysToStructArray(s)
% structArray = structOfArraysToStructArray(s)
% for a length 1 struct s with fields containing arrays of equal size in dimension dim,
% converts to a struct array where each element has the ith row/column/dim of those arrays
%
% e.g. for:
% s.a = [1 2], s.b = [21 22];
% structArray(1).a = 1; structArray(1).b = 21;
% structArray(2).a = 2; structArray(2).b = 22;
%

if nargin ~= 1
    error('Usage: sA = structOfArraysToStructArray(s');
end

flds = fieldnames(s);
nFlds = length(flds);

structArray = struct([]);
for ifld = 1:length(flds)
    % extract vals and ensure vals is a vector with the same size as previous vals
    vals = makecol([s.(flds{ifld})]);
    assert(isvector(vals), 'All fields in s must be vectors');
    if ~isempty(structArray)
        assert(length(vals) == length(structArray), 'All fields in s must have the same size in dimension 1');
    end

    % assign each element of vals into each struct in structArray
    if ~iscell(vals)
        vals = num2cell(vals);
    end
    [structArray(1:length(vals)).(flds{ifld})] = deal(vals{:});
end

end


