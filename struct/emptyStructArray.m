function S = emptyStructArray(sz, fields, varargin)
% S = emptyStructArray(sz, fieldsOrStruct, varargin)
% creates a struct array with a certain size sz and fields in cell array fields
% with all values set to optional param argument value = []

val = [];
value = [];
assignargs(varargin);

if nargin < 2
    fields = {};
end

if isempty(val) && ~isempty(value)
    val = value;
end

if isstruct(fields)
    fields = fieldnames(fields);
end

if isscalar(sz)
    sz = [sz 1];
end

% create a cell array the same size as sz
valsCell = cell(sz);
[valsCell{:}] = deal(val);

% create the argument list to pass to struct
nFields = length(fields);

if nFields > 0
    argsForStruct = cell(2*nFields, 1); 
    for i = 1:nFields
        argsForStruct{2*i-1} = fields{i};
        argsForStruct{2*i} = valsCell;
    end

    S = struct(argsForStruct{:});
elseif prod(sz) == 0
    S = struct(zeros(0, 1));
else
    S = struct();
    S(sz(1)) = S;
    S = makecol(S);
end
