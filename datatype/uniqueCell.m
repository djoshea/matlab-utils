function [B, I, J] = uniqueCell(A, varargin)
    removeEmpty = false;
    assignargs(varargin);

    B = {};
    I = [];
    J = zeros(numel(A),1);
    for iA = 1:numel(A)
        if removeEmpty && isempty(A{iA})
            I(iA) = NaN;
            J(iA) = NaN;
            continue;
        end
        
        idx = find(cellfun(@(b) isequal(A{iA}, b), B), 1, 'first');
        if isempty(idx)
            B{end+1} = A{iA};
            I(end+1) = iA;
            J(iA) = numel(B); 
        else
            J(iA) = idx;
        end
    end

end
