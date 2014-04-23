classdef ValueMap < DynamicClass
% ValueMap is a map container, very similar to containers.Map, except ValueMap
% is not a handle class. This allows it to be used within value classes without
% all value classes sharing a reference to a common map. It also supports
% arbitrary key types (by using DataHash internally).
%
% It supports similar key read and write syntax as containers.Map, e.g.
%
%   value = map(key)
%   map(key) = value
%  
%  This functionality is provided by utilizing DynamicClass
%

    properties
        KeyType
        ValueType
        storeKeys
    end
    
    properties(Dependent)
        Count
    end

    properties(Hidden)
        hashStruct = struct(); 
        keySet = {};
        keyValidator
        valueValidator
    end

    methods
        function map = ValueMap(varargin)
            p = inputParser;
            p.addOptional('KeySet', {}, @(x) ~ischar(x) && (isempty(x) || isvector(x)));
            p.addOptional('ValueSet', {}, @(x) ~ischar(x) && (isempty(x) || isvector(x)));
            p.addParamValue('UniformValues', false, @islogical);
            p.addParamValue('StoreKeys', true, @islogical);
            p.addParamValue('KeyType', '', @ischar);
            p.addParamValue('ValueType', '', @ischar);
            p.parse(varargin{:});
            
            map.KeyType = p.Results.KeyType;
            map.ValueType = p.Results.ValueType;
            map.storeKeys = p.Results.StoreKeys;
            uniformValues = p.Results.UniformValues;
            keySet = p.Results.KeySet; %#ok<*PROP>
            valueSet = p.Results.ValueSet;

            % infer KeyType if necessary
            if isempty(map.KeyType)
                if ~isempty(keySet) 
                    % infer key type from key set
                    if iscellstr(keySet)
                        map.KeyType = 'char';
                    elseif isnumeric(keySet)
                        map.KeyType = class(keySet);
                    else
                        map.KeyType = 'any';
                    end
                else
                    map.KeyType = 'char';
                end
            end

            % infer ValueType if necessary
            if ~uniformValues
                map.ValueType = 'any';
            elseif isempty(map.ValueType)
                if ~isempty(valueSet) 
                    % infer value type from key set
                    if iscellstr(valueSet)
                        map.ValueType = 'char';
                    elseif isnumeric(valueSet) || islogical(valueSet)
                        map.ValueType = class(keySet);
                    else
                        map.ValueType = 'any';
                    end
                else
                    map.ValueType = 'any';
                end
            end

            % check lengths match
            if ~isempty(valueSet)
                assert(length(valueSet) == length(keySet), ...
                    'Lengths of ValueSet and KeySet must match');
            end
                
            % pick validator function for keys
            switch map.KeyType
                case {'char', 'double', 'single', 'int32', 'uint32', 'int64', 'uint64'}
                    map.keyValidator = @(x) isa(x, map.KeyType);
                case 'any'
                    map.keyValidator = @(x) true;
                otherwise
                    error('Unknown KeyType %s', map.KeyType);
            end

            % pick validator function for values
            switch map.ValueType
                case {'char', 'logical', 'double', 'single', 'int8', 'uint8', 'int16', ...
                        'uint16', 'int32', 'uint32', 'int64', 'uint64'}
                    map.valueValidator = @(x) isa(x, map.KeyType);
                case 'any'
                    map.valueValidator = @(x) true;
                otherwise
                    error('Unknown KeyType %s', map.KeyType);
            end

            % use .set to store initial keySet -> valueSet
            if ~isempty(keySet)
                for i = 1:length(keySet)
                    if iscell(keySet)
                        key = keySet{i};
                    else
                        key = keySet(i);
                    end
                    if iscell(valueSet)
                        value = valueSet{i};
                    else
                        value = valueSet(i);
                    end

                    map = map.set(key, value);
                end
            end
        end

        function assertKeyValid(map, key)
            assert(map.keyValidator(key), 'Key is invalid for KeyType %s', map.KeyType); 
        end

        function assertValueValid(map, value)
            assert(map.valueValidator(value), 'Value is invalid for ValueType %s', map.ValueType); 
        end

        function keyHash = hashKey(map, key) %#ok<INUSL>
            if ischar(key)
                if isvarname(key)
                    keyHash = key;
                else
                    keyHash = genvarname(key);
                end 
                % removing since doesn't work for vectors
            %elseif isnumeric(key)
            %    keyHash = genvarname(num2str(key));
            else
                %map.assertKeyValid(key);  
                opts.Method = 'MD5';
                opts.format = 'hex';
                keyHash = ['s' DataHash(key, opts)];
            end
        end

        function map = set(map, key, value)
            map.warnIfNoArgOut(nargout);
            hash = map.hashKey(key);
            
            % add the key to our list if not present
            % could call isKey but want to avoid hashing twice
            if map.storeKeys && ~isfield(map.hashStruct, hash)
                map.keySet{end+1} = key;
            end

            % store the value in hashStruct
            map.hashStruct.(hash) = value;
        end

        function map = add(map, otherMap)
            map.warnIfNoArgOut(nargout);
            otherKeys = otherMap.keys;
            for iKey = 1:length(otherKeys)
                key = otherKeys{iKey};
                map = map.set(key, otherMap.get(key));
            end
        end

        function tf = isKey(map, key)
            map.assertKeyValid(key);  
            tf = isfield(map.hashStruct, map.hashKey(key));
        end

        function value = get(map, key)
            hashKey = map.hashKey(key);
            assert(isfield(map.hashStruct, hashKey), 'Key not found');
            value = map.hashStruct.(hashKey);
        end

        function map = remove(map, keys)
            map.warnIfNoArgOut(nargout);
            if ~iscell(keys)
                keys = {keys};
            end
            for iKey = 1:length(keys)
                key = keys{iKey};
                hashKey = map.hashKey(key);
                if ~isfield(map.hashStruct, hashKey)
                    fprintf('Warning: The key to be removed is not present in this container');
                else
                    map.hashStruct = rmfield(map.hashStruct, hashKey);
                    if map.storeKeys
                        idx = cellfun(@(storedKey) isequaln(key,storedKey), map.keySet);
                        map.keySet = map.keySet(~idx);
                    end
                end
            end
        end

        function map = keepOnly(map, keys)
            map.warnIfNoArgOut(nargout);
            if ~iscell(keys)
                keys = {keys};
            end
            removeKeys = setdiff(map.keys, keys);
            map = map.remove(removeKeys);
        end

        function len = length(map)
            len = map.Count;
        end

        function count = get.Count(map)
            count = length(fieldnames(map.hashStruct));
        end

        function varargout = size(map, dim) 
            if nargin == 1
                varargout{1} = map.Count;
                varargout{2} = 1;
            elseif dim == 1
                varargout{1} = map.Count;
            else
                varargout{1} = 1;
            end
        end

        function keyList = keys(map)
            assert(map.storeKeys, 'This map does not store key values. Try passing ''StoreKeys'', true to the constructor');
            keyList = map.keySet;
        end

        function warnIfNoArgOut(map, nargOut)
            if nargOut == 0
                warning('%s is not a handle class. If the instance handle returned by this method is not stored, this call has no effect.', ...
                    class(map));
            end
        end
    end

    methods % Dynamic property access
        function [result, appliedNext] = parenIndex(map, subs, typeNext, subsNext) %#ok<INUSD>
            if length(subs) ~= 1;
                result = DynamicClass.NotSupported;
                appliedNext = false;
            else
                result = map.get(subs{1});
                appliedNext = false;
            end
        end

        function map = parenAssign(map, subs, value, s)
            map.warnIfNoArgOut(nargout);
            if length(subs) ~= 1 || ~isempty(s)
                map = DynamicClass.NotSupported;
            else
                map = map.set(subs{1}, value);
            end
        end
    end

end
