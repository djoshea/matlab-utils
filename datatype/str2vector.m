function [vec valid] = str2vector(str, varargin)
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

emptyValue = NaN;
invalidValue = NaN;
assignargs(varargin);

if ischar(str)
    single = true;
    strCell = {str};
elseif iscell(str)
    single = false;
    strCell = str;
else
    error('Requires char or cell array argument');
end


for iStr = 1:length(strCell)
    str = strCell{iStr};

    if isempty(str)
        vecCell{iStr} = emptyValue;
        valid(iStr) = true;
        continue;
    end

    if ~ischar(str)
        vecCell{iStr} = invalidValue;
        valid(iStr) = false;
        continue;
    end

    str = strtrim(str);
    
    % figure out which delimiter we're using to separate the values
    % semicolon, comma, or space
    if any(str == ';')
        delim = ';';
        multDelimsAsOne = false;
        orientFn = @makecol;
    elseif any(str == ',')
        delim = ',';
        multDelimsAsOne = false;
        orientFn = @makerow;
    else
        delim = ' ';
        multDelimsAsOne = true;
        orientFn = @makerow;
    end

    % strip surrounding [] 
    if str(1) == '['
        str = str(2:end);
    end
    if str(end) == ']'
        str = str(1:end-1);
    end
    str = strtrim(str);
    if isempty(str)
        vecCell{iStr} = emptyValue;
        valid(iStr) = true;
        continue;
    end

    results = textscan(str, '%s', 'Delimiter', delim, 'MultipleDelimsAsOne', multDelimsAsOne);
    tokens = results{1};

    ignoreMask = cellfun(@(x) isempty(x) || strcmp(x, 'NaN'), tokens);

    vec = str2double(tokens);
    valid(iStr) = ~any(isnan(vec) & ~ignoreMask);
    vecCell{iStr} = orientFn(vec);
end

if single
    vec = vecCell{1};
else
    vec = vecCell;
end

