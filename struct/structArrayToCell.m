function C = structArrayToCell(S)
    % converts a struct array to a cell array of the same size, with each cell field
    % containing exactly one element of the struct array

    C = arrayfun(@(s) s, S, 'UniformOutput', false);

end
