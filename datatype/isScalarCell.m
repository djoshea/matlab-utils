function [tf, mat] = isScalarCell(c, varargin)
% [tf mat] = isScalarCell(c)
%    returns true if each entry in cell array c is a numeric type or empty
% [tf mat] = isScalarCell(c, 'ignoreEmpty', false)
%    returns true if each entry in cell array c is a numeric type 

p = inputParser();
p.addParamValue('ignoreEmpty', true, @islogical);
p.parse(varargin{:});
ignoreEmpty = p.Results.ignoreEmpty;

if isempty(c)
    tf = true;
    mat = [];
    return;
end

if ~iscell(c)
    tf = false;
    mat = [];
    return;
end

% for i = 1:numel(c)
%     v = c{i};
%     if (~ignoreEmpty && isempty(v)) && (~isscalar(v) || (~isnumeric(c) && ~islogical(c)))
%         % simple shortcut
%         tf = false;
%         mat = [];
%         return;
%     end
% end

% figure out which cells are currently nans
nanMask = cellfun(@(c) isnumeric(c) && all(isnan(c)),c);

% true if cell is empty
emptyMask = cellfun(@(x) isempty(x) || (ischar(x) && isempty(strtrim(x))), c);

% find cells which already contain sclar
scalarMask = cellfun(@(x) isscalar(x) && all(isnumeric(x) | islogical(x)), c);

% figure out which entries are either numeric/nan/empty and can safely be ignored
if ignoreEmpty
    ignoreMask = scalarMask | nanMask | emptyMask;
else
    ignoreMask = scalarMask | nanMask;
end

% figure out which cells have strings with commas
% str2double ignores these, but we can't accept them because
% they are often used to delineate lists of numbers, which would make that
% cell non-scalar
hasCommaMask = cellfun(@(x) ischar(x) && any(x==','), c);

% convert the matrix to numeric or NaN
mat = str2double(c);

conversionFailedMask = arrayfun(@isnan, mat);

% a cell is invalid if str2double didn't like it or it has a comma
% but it wasn't scalar or empty or Nan to begin with
invalidMask = (conversionFailedMask | hasCommaMask) & ~ignoreMask;

if any(scalarMask)
    mat(scalarMask) = double([c{scalarMask}]); 
end
if any(hasCommaMask)
    mat(hasCommaMask) = NaN;
end
if any(emptyMask)
    mat(emptyMask) = NaN;
end

tf = ~any(invalidMask);

