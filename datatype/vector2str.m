function str = vector2str(vec, varargin)
% parses a vector specified as a string that looks like
% '[1,2,3,4]', '[1 2 3 4]', '1 2 3 4', or '1,2,3,4'
% 
%  vec is the parsed vector or [] if valid == false
%  if the string is blank or the vector doesn't contain any values
%  vec will == emptyValue, which is by default NaN (not []) and can be overriden
%  using str2vector(str, 'emptyValue', emptyValue);
%
%  if str is a cell array of strings, vec will be a cell array of vectors and 
%  valid will be a logical array of the same size

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

