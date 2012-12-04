function pv = structToParamValue(S)
% convert a struct to a {'param', value, 'param2', value2} parameter/value
% pair argument list

fields = fieldnames(S);
values = struct2cell(S);

pv = cell(1, length(fields)*2);
pv(1:2:end) = fields;
pv(2:2:end) = values;
