function [S stripped] = structStripFields(S, fields)
% [remaining stripped] = structStripFields(S, fields)
% For each field in fields{:}, remove S.field from S and add it to stripped.S
% Note: if S does not have any of the fields in fields, stripped will be []

if ischar(fields)
    fields = {fields};
end

stripped = [];
for ifld = 1:length(fields)
    if ~isfield(S, fields{ifld})
        continue;
    end

    % need to copy individually in case any are empty
    for is = 1:length(S)
        stripped(is).(fields{ifld}) = S(is).(fields{ifld});
    end

    S = rmfield(S, fields{ifld}); 
end

end
