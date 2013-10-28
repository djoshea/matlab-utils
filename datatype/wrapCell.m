function v = wrapCell(v)
% v = wrapCell(v)
% Wrap v as cell {v} if ~iscell(v)

    if ~iscell(v)
        v = {v};
    end

end