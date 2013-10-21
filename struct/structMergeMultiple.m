function merged = structMergeMultiple(varargin)
% merge many scalar structs

if isempty(varargin)
    merged = struct();
    return;
end

merged = varargin{1};
for i = 2:numel(varargin)
    new = varargin{i};
    flds = fieldnames(new);
    for f = 1:numel(flds)
        merged.(flds{f}) = new.(flds{f});
    end
end

end
