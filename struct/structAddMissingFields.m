function [withAddedFields, fieldsToAdd] = structAddMissingFields(addTo, toMatchThis, varargin)
% withAddedFields = structAddMissingFields(addTo, toMatchThis)

def.ignoreFields = {};
def.ignoreEmpty = false;
assignargs(def, varargin);

if isempty(toMatchThis)
    withAddedFields = addTo;
    fieldsToAdd = {};
    return;
end
    
if isempty(addTo)
    if ignoreEmpty
        withAddedFields = addTo;
        fieldsToAdd = {};
    else
        withAddedFields = emptyStruct(toMatchThis);
        withAddedFields = withAddedFields(false(size(withAddedFields)));
        fieldsToAdd = fieldnames(toMatchThis);
    end
    
else
    fieldsToAdd = setdiff(setdiff(fieldnames(toMatchThis), fieldnames(addTo)), ignoreFields);

    for ifld = 1:length(fieldsToAdd)
        [addTo.(fieldsToAdd{ifld})] = deal([]);
    end

    withAddedFields = orderfields(addTo);
end

