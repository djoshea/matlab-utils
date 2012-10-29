function S = emptyStructArray(sz, fields, varargin)
% creates a struct array with a certain size sz and fields in cell array fields
% with all values set to optional argument val = []

val = [];
assignargs(varargin);

% create a cell array the same size as sz
valsCell = cell(sz);
[valsCell{:}] = deal(val);

% create the argument list to pass to struct
nFields = length(fields);
argsForStruct = cell(2*nFields, 1); 
for i = 1:nFields
    argsForStruct{2*i-1} = fields{i};
    argsForStruct{2*i} = valsCell;
end

S = struct(argsForStruct{:});
