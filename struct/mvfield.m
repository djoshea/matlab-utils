function S = mvfield(Sin, fromFields, toFields, Ssrc)
% S = mvfield(Sin, fromFields, toFields, [SSource = Sin])
% rename a field in a structure. If arguments are cells, will rename all
% fields in parallel (so that b --> c, a --> b works as expected)

    if nargin < 4
        Ssrc = Sin;
    end
    if ~iscell(fromFields)
        fromFields = {fromFields};
        toFields = {toFields};
    end
    S = rmfield(Sin, intersect(fieldnames(Sin), fromFields));
    for iA = 1:numel(fromFields)
        [S(:).(toFields{iA})] = Ssrc.(fromFields{iA});
    end

end