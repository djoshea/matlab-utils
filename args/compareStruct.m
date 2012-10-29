function equal = compareStruct(A,B)
    % shallow comparison of structs (only == for first layer fields
    equal = false;
    fldA = sort(fieldnames(A));
    fldB = sort(fieldnames(B));
    if(length(fldA) ~= length(fldB) || ~all(strcmp(fldA,fldB)))
        return;
    else
        for iFld = 1:length(fldA)
            fldName = fldA{iFld};
            if(~isequal(A.(fldName), B.(fldName)) && ~any(isnan(A.(fldName))) && ~any(isnan(B.(fldName))))
                % if they're not equal (and not both nans)
                return
            end
        end
    end
    
    equal = true;
end
