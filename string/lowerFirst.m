function capStr = lowerFirst(str)
% capStr = lowerFirst(str)
% lower cases the first letter of str or of each element of str{:}

fn = @(str) strcat(lower(str(1)), str(2:end));

if iscellstr(str)
    capStr = cellfun(fn, str, 'UniformOutput', false);
elseif ischar(str)
    capStr = fn(str);
elseif isstring(str)
    capStr = cellfun(@(s) string(fn(char(s))), str, 'UniformOutput', true);
else
    error('lowerFirst accepts char or cellstr argument');
end
    
end