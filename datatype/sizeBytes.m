function totalBytes = sizeBytes(nameList)

vars = evalin('caller', 'whos');

if ischar(nameList)
    nameList = {nameList};
end

if ~iscell(nameList)
    error('Please pass the names as strings, not the variables themselves');
end

totalBytes = 0;

for i = 1:length(nameList)
    ind = find(strcmp({vars.name}, nameList{i}));
    if isempty(ind)
        error('Variable %s not found', nameList{i})
    end
    totalBytes = vars(ind).bytes;
end
