function S = structReplaceEmptyValues(S, varargin)
% for each field in 'fields', replaces empty values of S(i).(field) with 'with'
    if isempty(S)
        fields = {};
    else
        fields = fieldnames(S);
    end
    
    % replace all empty values with this:
    with = NaN;
    
    % empty strings ('') are typically not a problem
    % as they do not collapse when gathering fields from a struct array as in
    % {S.charField}, wheras empty numeric values do
    replaceEmptyStrings = false; 

    assignargs(varargin);

    if replaceEmptyStrings
        emptyFn = @isempty;
    else
        emptyFn = @(x) isempty(x) && ~ischar(x);
    end

    for iF = 1:length(fields)
        fld = fields{iF};
        [S(cellfun(emptyFn, {S.(fld)})).(fld)] = deal(with);
    end
end
