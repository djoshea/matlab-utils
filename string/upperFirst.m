function capStr = upperFirst(str)
% capStr = firstUpper(str)
% capitalizes the first letter of str

fn = @(str) strcat(upper(str(1)), str(2:end));

if iscellstr(str)
    capStr = cellfun(fn, str);
elseif ischar(str)
    capStr = fn(str);
else
    error('firstUpper accepts char or cellstr argument');
end
    
end