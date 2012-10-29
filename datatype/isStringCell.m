function [tf c] = isStringCell(c, varargin)
% [tf c] = isStringCell(c, ['convertScalar', true], ['convertVector', true])
%    returns true if each entry in cell array c is a string type or empty
% if 'convertScalar' is true, will convert scalar numbers to strings first 

convertScalar = false;
convertVector = false;
assignargs(varargin);

if isempty(c)
    c = {};
    tf = true;
end

tf = false;
cstr = {};

if ~iscell(c)
    if ~isvector(c)
        return
    end
    if convertScalar || convertVector
        % convert to cell array from numeric vector
        c = num2cell(c);
    else
        return;
    end
end

emptyOrNanMask = cellfun(@(x) isempty(x) || (isnumeric(x) && all(isnan(x))), c);
[c{emptyOrNanMask}] = deal('');

if convertScalar
    numMask = cellfun(@(x) isscalar(x) && all(isnumeric(x)) || all(islogical(x)), c);
    numReplace = cellfun(@num2str, c(numMask), 'UniformOutput', false);
    c(numMask) = numReplace;
end
if convertVector
    numMask = cellfun(@(x) all(isnumeric(x) | islogical(x)), c);
    numReplace = vector2str(c(numMask));
    c(numMask) = numReplace;
end

tf = iscellstr(c);

end
