function S = mapToStructArray(map, varargin)
    % map is a containers.Map. Extract the values of each key, treat the values as
    % vectors of the same length, and create a struct array where the fields are 
    % the key names and element i of map(fieldName) is stored as S(i).fieldName

    p = inputParser;
    p.addParamValue('convertNames', false, @islogical);
    p.parse(varargin{:});
    convertValues = p.Results.convertNames; 

    keys = map.keys;
    nKeys = length(keys);

    S = struct([]);
    for iKey = 1:nKeys
        key = keys{iKey};

        if ~isvarname(key)
            if convertValues
                key = genvarname(key, keys(1:iKey-1));
                keys{iKey} = key;
            else
                error('%s is not a valid struct field name', key);
            end
        end 

        values = map(key);

        if iKey == 1
            lenS = length(values);
        else
            assert(length(values) == lenS, ...
                'Values for key %s is not the same length as other keys'' values', key);
        end

        S = assignIntoStructArray(S, key, values);
    end

    S = makecol(S);

end
