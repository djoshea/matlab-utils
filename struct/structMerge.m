function [merged overlap] = structMerge(target, source, varargin);
% [merged overlap] = structMerge(target, source, varargin);

def.warnOnOverwrite = false;
def.ignoreOverwrite = {}; % list of fields to ignore when warning on overwritten fields
def.selectSourceFields = false; % list of fields in source to copy ( {} of strings ), or false to copy all
def.renameTo = false;
assignargs(def, varargin);

% check that lengths match
assert(length(target) == length(source) || isempty(target));

if ischar(selectSourceFields)
    selectSourceFields = {selectSourceFields};
end
if ischar(renameTo) 
    renameTo = {renameTo};
end
assert(length(selectSourceFields) == length(renameTo) || ~renameTo);

sourceFields = fieldnames(source);

if iscell(selectSourceFields)
    assert(all(ismember(selectSourceFields, sourceFields)), 'Some fields not found in original struct');
    sourceFields = selectSourceFields; 
end

if iscell(renameTo)
    destFields = renameTo;
else
    destFields = sourceFields;
end
targetFields = fieldnames(target);

% check for non-ignored overlap in the field names
overlap = setdiff(intersect(destFields, targetFields), ignoreOverwrite);
if warnOnOverwrite && ~isempty(overlap)
    for iov = 1:length(overlap)
        fprintf(2, '\t\tOverwriting field %s in target with source\n', overlap{iov});
    end
end

merged = target;
if isempty(merged)
	% can't do dot assignment to 0x0 struct array, struct() returns 1x1 empty
	% struct
	merged = struct();
end
for it = 1:numel(source)
    for ifld = 1:length(sourceFields)
        merged(it).(destFields{ifld}) = source(it).(sourceFields{ifld});
    end
end

end
