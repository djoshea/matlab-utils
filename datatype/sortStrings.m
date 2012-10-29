function [sorted idx] = sortStrings(strings, varargin)
    p = inputParser;
    p.addRequired('strings', @iscellstr);
    p.addOptional('mode', 'ascend', @(s) ismember(s, {'ascend', 'descend'}));
    p.parse(strings, varargin{:});
    mode = p.Results.mode;

    if strcmp(mode, 'ascend')
        col = 1; 
    else
        col = -1;
    end

    [sorted idx] = sortrows(makecol(strings), col);
end
