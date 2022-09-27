function capStr = upperFirst(str)
% capStr = firstUpper(str)
% capitalizes the first letter of str

fn = @(str) strcat(upper(str(1)), str(2:end));

if isstring(str)
    capStr = strings(size(str));
    for iS = 1:numel(str)
        capStr(iS) = upper(extractBefore(str(iS), 2)) + extractAfter(str(iS), 1);
    end
elseif iscellstr(str)
    capStr = cellfun(fn, str, 'UniformOutput', false);
elseif ischar(str)
    capStr = fn(str);
else
    error('upperFirst accepts char or cellstr argument');
end
    
end