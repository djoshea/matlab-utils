function list = multiDir(varargin)
    % list = multiDir('wildcardSearch1', 'wildcardSearch2', ...) 
    % Works identically to dir but combines the results of the searches together into one struct array
    % Also prepends the directory path onto each names
    
    if nargin == 0
        error('Usage: multiDir(search1, search2, ...)');
    end

    % allow args to be passed as cell or argument list
    if iscell(varargin{1})
        args = varargin{1};
    else
        args = varargin;
    end

    resultsCell = cell(length(args), 1);
    for i = 1:length(args)
        r = dir(args{i});
        
        if ~isempty(r)
            path = fileparts(args{i});
            fullNames = cellfun(@(name) fullfile(path, name), {r.name}, 'UniformOutput', false);
            [r.name] = fullNames{:};
        end
        resultsCell{i} = r;
    end

    list = cat(1, resultsCell{:}); 
end
