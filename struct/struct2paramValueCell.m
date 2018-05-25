function args = struct2paramValueCell(s)
    flds = fieldnames(s)';
    args = flds;
    if isempty(args)
        args = {};
    else
        args(2, :) = cellfun(@(f) s.(f), flds, 'UniformOutput', false);
        args = args(:);
    end
    
    
    
end
    