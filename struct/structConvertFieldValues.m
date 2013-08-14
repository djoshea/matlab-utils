function S = structConvertFieldValues(S, to, fields)
% S = structConvertFieldValues(S, to, fields)

if nargin < 3
    fields = fieldnames(S);
end

if ~iscell(fields)
    fields = {fields};
end

if isa(to, 'function_handle')
    fn = to;
else
    fn = @(x) cast(x, to);
end

for field = fields
    vals = cellfun(fn, {S.(field{:})}, 'UniformOutput', false);
    [S(:).(field{:})] = vals{:};
end

end