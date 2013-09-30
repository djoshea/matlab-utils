function str = vector2str(vec, varargin)


separator = ',';
braceIfNonScalar = false;
braceAlways = false;
assignargs(varargin);

isNumVecFn = @(vec) (isempty(vec) || isvector(vec)) && all(isnumeric(vec) | islogical(vec));
braceFn = @(str) ['[' str ']'];

if isNumVecFn(vec)
    single = true;
    vecCell = {vec};
elseif iscell(vec)
    single = false;
    vecCell = vec;
    assert(all(cellfun(isNumVecFn, vecCell)), 'Cell array may contain only numeric vectors');
else
    error('Requires numeric vector or cell array argument');
end

vec2strCellFn = @(vec) arrayfun(@num2str, vec, 'UniformOutput', false);
strCell = cellfun(@(vec) strjoin(vec2strCellFn(vec), separator), vecCell, 'UniformOutput', false);
if braceAlways
    braceMask = true(size(strCell));
elseif braceIfNonScalar
    braceMask = cellfun(@isscalar, vecCell);
else
    braceMask = [];
end

if any(braceMask)
    strCell(braceMask) = cellfun(braceFn, strCell(scalarMask), 'UniformOutput', false);
end

if single
    str = strCell{1};
else
    str = strCell;
end

