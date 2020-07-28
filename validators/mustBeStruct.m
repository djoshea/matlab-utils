function mustBeStruct(A)
    if ~isstruct(A)
        throwAsCaller(MException('MATLAB:validators:mustBeStruct', 'Argument must be a struct'));
    end
end

