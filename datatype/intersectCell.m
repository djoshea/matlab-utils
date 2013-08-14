function [C, IA, IB] = intersectCell(A, B, mode)
% works the same as intersect, but accepts arbitrary cell arrays, 
% not just of strings
% two possibilities for cells
% either it's a cell array of strings, or it has vectors with various sizes

    if isnumeric(A) || islogical(A)
        if isnumeric(B) || islogical(B)
            % just use usual intersect when both are numeric
            [C, IA, IB] = intersect(A,B);
            return;
        else
            % A is numeric, b is not
            A = num2cell(A);
        end
    else
        % A is not numeric
        if isnumeric(B) || islogical(B)
            B = num2cell(B);
        end
    end

    % now both A and B are cells
    
    % which ones in A are also in B?
    locAInB = cellfun(@(a) findInCell(a, B), A);
    maskAInBoth = locAInB > 0;
    
    C = A(maskAInBoth);
    IA = find(maskAInBoth);
    IB = locAInB(maskAInBoth);
    
    if nargin < 3 || strcmp(mode, 'stable')
        return;
    end
   
    error('Mode not supported');
end

function idx = findInCell(a, B)
    % find a in cell S or return 0
    idx = find(cellfun(@(b) isequal(a,b), B), 1, 'first');
    if isempty(idx)
        idx = 0;
    end
end
