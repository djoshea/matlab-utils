function out = structClearFields(in, sz)
    flds = fieldnames(in);
    for i = 1:numel(flds)
        out.(flds{i}) = [];
    end
    
    if nargin > 1
        out = repmat(out, sz);
    end
end