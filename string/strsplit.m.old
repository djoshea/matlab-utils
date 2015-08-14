function tokens = strsplit(str, separator)
% creates a string by splitting the elements of strCell, separated by the string
% in separator, ignoring spaces 
% internally uses repeated strtok calls to do the splitting
% e.g. str = '3,4, 5', separator = ',' [ default ] --> strCell = {'3','4','5'}

if nargin < 2
    separator = ',';
end

if isempty(str)
    tokens = {};
    return;
end

results = textscan(str, '%s', 'Delimiter', separator);
tokens = results{1};

end
