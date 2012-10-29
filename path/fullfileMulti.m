function list = fullfileMulti(varargin)
% list = fullfileMulti(d1cell, d2cell, ...)
% builds a combinatorial list of file names by concatenating each 
% d#cell1{i}/d#cell2{j}/... for i, j, ...

% build list of strings and number of strings
nArgs = length(varargin);
argList = cell(nArgs, 1);
idxList = cell(nArgs, 1);
for i = 1:nArgs
    if iscell(varargin{i})
        argList{i} = varargin{i};
    elseif ischar(varargin{i})
        argList{i} = {varargin{i}};
    else
        error('Each argument must be a string of cellstr');
    end

    nList(i) = length(argList{i});
    idxList{i} = 1:nList(i);
end

% loop through list using flat inds and use ind2sub to find the right
% indices for each arg
list = cell(prod(nList), 1);
for flatInd = 1:length(list)
    % get the subscripts for this combination
    [subCell{1:nArgs}] = ind2sub(nList, flatInd);
    values = arrayfun(@(i) argList{i}{subCell{i}}, 1:nArgs, 'UniformOutput', false);

    list{flatInd} = fullfile(values{:});
end

end

