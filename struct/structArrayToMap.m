function map = structArrayToMap(S, varargin)
    % S is a struct array. Extract the values of each field, place the values into
    % arrays of the same size (either numeric or cell array).
    % map is a containers.Map : field name -> values vector

    p = inputParser;
    p.addRequired('S', @isstruct);
    p.addParamValue('valueType', 'any', @ischar);
    p.parse(S, varargin{:});

    valueType = p.Results.valueType;
    keys = fieldnames(S);
    nKeys = length(keys);

    map = containers.Map('KeyType', 'char', 'ValueType', valueType);

    for iKey = 1:nKeys
        key = keys{iKey};

        % first place in cell array
        values = {S.(key)};

        % attempt to build scalar cell if all values are scalar 
        [tf valuesVector] = isScalarCell(values);
        if tf
            values = valuesVector;
        end

        map(key) = makecol(values);
    end

end
