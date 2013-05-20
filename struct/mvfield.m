function S = mvfield(Sin, fromFields, toFields)
% rename a field in a structure. If arguments are cells, will rename all
% fields in parallel (so that b --> c, a --> b works as expected)

    if ~iscell(fromFields)
        fromFields = {fromFields};
        toFields = {toFields};
    end
    S = rmfield(Sin, fromFields);
    for iA = 1:numel(fromFields)
        [S(:).(toFields{iA})] = Sin.(fromFields{iA});
    end

end