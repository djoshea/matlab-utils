function [S mask] = filterStruct(S, varargin)

filters = structargs([], varargin);
flds = fieldnames(filters);
nFilters = length(flds);

if isempty(S)
    mask = [];
    return;
end

mask = true(length(S), 1);
for ifld = 1:nFilters
    % get values from struct
    vals = {S.(flds{ifld})}';

    % get constraints and test them
    constraint = filters.(flds{ifld});
    if ischar(constraint)
        mask = mask & strcmp(vals, constraint);
    else
        % convert to numeric array
        vals = cell2mat(vals);
        if length(constraint) == 2
            % treat as range
            mask = mask & inRange(vals, constraint);
        else
            mask = mask & vals == constraint;
        end
    end
end

S = S(mask);


