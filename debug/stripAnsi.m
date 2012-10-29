function strCell = stripAnsi(str)
% remove ansi escape codes, can accept cellstr 

if ischar(str)
    strCell = {str};
    returnCell = false;
elseif iscell(str)
    strCell = str;
    returnCell = true;
else
    error('Must pass string or cellstr');
end

pat = '\033\[[\d;]*m';
strCell = cellfun(@(str) regexprep(str, pat, ''), strCell, ...
    'UniformOutput', false); 

if ~returnCell
    strCell = strCell{1};
end

end
