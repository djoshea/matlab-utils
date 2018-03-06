function [tf vecCell] = isVectorCell(c, varargin)
% [tf vecCell] = isVectorCell(c)
%    returns true if each entry in cell array c is a numeric vector type or may be
%    converted to a number from a string using str2double. Empty values are accepted
%    and replaced with NaN
% [tf vecCell] = isVectorCell(c, 'ignoreEmpty', false)
%    returns true if each entry in cell array c is a numeric vector type. Empty values
%    are not accepted

ignoreEmpty = true;
logicalOkay = true;
emptyValue = [];
assignargs(varargin);

if ~iscell(c)
    if isnumeric(c) || islogical(c)
        c = num2cell(c);
    else
        tf = false;
        vecCell = [];
        return;
    end
end

% figure out which cells are currently nans
nanMask = cellfun(@(c) isnumeric(c) && all(isnan(c)),c);

% true if cell is empty
emptyMask = cellfun(@(x) isempty(x) || (ischar(x) && isempty(strtrim(x))), c);

% find cells which already contain numeric vectors
if logicalOkay
    numericMask = cellfun(@(x) isvector(x) && all(isnumeric(x) | islogical(x)), c);
else
    numericMask = cellfun(@(x) isvector(x) && all(isnumeric(x)), c);
end

% figure out which entries are either numeric/nan/empty and can safely be ignored
if ignoreEmpty
    ignoreMask = makecol(numericMask | nanMask | emptyMask);
else
    ignoreMask = makecol(numericMask | nanMask);
end

% convert the matrix to numeric or NaN
[vecCell validMask] = str2vector(c);
conversionFailedMask = makecol(~validMask);

% a cell is invalid if str2double didn't like it or it has a comma
% but it wasn't scalar or empty or Nan to begin with
invalidMask = conversionFailedMask & ~ignoreMask;

if any(numericMask)
    vecCell(numericMask) = c(numericMask); 
end
if any(emptyMask)
    [vecCell{emptyMask}] = deal(emptyValue);
end

tf = ~any(invalidMask);


