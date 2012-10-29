function S = assignIntoStructArray(S, fld, vals, idx)
% S = assignIntoStructArray(S, fld, vals, idx)
% for each element s in struct array S(idx), efficiently assigns
% s.(fld) = the corresponding element from vals.

    if ~exist('idx', 'var')
        if isempty(S)
            idx = 1:length(vals);
        else
            idx = 1:length(S);
            %assert(length(S) == length(vals), 'Sizes of S and vals do not match');
        end
   % else
   %     assert(nnz(idx) == length(vals), 'Sizes of idx and vals do not match');
    end
    
    if ischar(vals)
        vals = {vals};
    end
    assert(isempty(S) || nnz(idx) == numel(vals) || numel(vals) == 1, ...
        'S(idx) and vals must have same size or vals must be length 1');
    n = numel(idx);


    


    if isnumeric(vals) || islogical(vals)
        vals = num2cell(vals);
    end

    [S(idx).(fld)] = deal(vals{:});

end
