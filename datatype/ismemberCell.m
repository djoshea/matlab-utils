function [tf loc] = ismemberCell(A, S)
% works the same as ismember, but accepts arbitrary cell arrays, not just of strings
% two possibilities for cells
% either it's a cell array of strings, or it has vectors with various sizes

    if isnumeric(A) || islogical(A)
        if isnumeric(S) || islogical(S)
            % just use usual ismember
            [tf loc] = ismember(A,S);
            return;
        end
        A = num2cell(A);
    end
    if isnumeric(S) || islogical(A)
        S = num2cell(S);
    end
    if ischar(A)
        A = {A};
    end

    loc = cellfun(@(a) findInCell(a, S), A);
    tf = loc > 0;

end

function idx = findInCell(a, S)
    % find a in cell S or return 0
    idx = find(cellfun(@(s) isequal(a,s), S), 1, 'first');
    if isempty(idx)
        idx = 0;
    end
end
