function list = multiDir(varargin)
    % list = multiDir('wildcardSearch1', 'wildcardSearch2', ...) 
    % Works identically to dir but combines the results of the searches together into one struct array
    
    if nargin == 0
        error('Usage: multiDir(search1, search2, ...)');
    end

    % allow args to be passed as cell or argument list
    if iscell(varargin{1})
        args = varargin{1};
    else
        args = varargin;
    end

    resultsCell = cellfun(@dir, args, 'UniformOutput', false);

    list = cat(1, resultsCell{:}); 
end
