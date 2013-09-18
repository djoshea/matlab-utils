function [S, invalid]= removeInvalidFields(S)
% removes fields from S which are not valid field names
% this occasionally happens in MAT files written by buggy MEX code

    names = fieldnames(S);
    valid = cellfun(@isvarname, names);
    S = rmfield(S, names(~valid));
    
    if nargout > 1
        invalid = names(~valid);
    end
end