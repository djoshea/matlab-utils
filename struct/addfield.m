function S = addfield(S, fld, vals)
% S = assignIntoStructArray(S, fld, vals, idx)
% for each element s in struct array S(idx), efficiently assigns
% s.(fld) = the corresponding element from vals.
%
% vals must either be a numel(S) vector or numel(S) x numel(fld)
% cell/matrix
% 
% If fld is a cellstr, assigns vals(iS, iFld) into each field in fld{:}
     
    % cell wrap fld
    if ~iscell(fld)
        fld = {fld};
    end
    
    % cell wrap vals
    if ischar(vals) || isempty(vals)
        vals = {vals};
    elseif ~iscell(vals)
        vals = num2cell(vals);
    end
    
    % scalar expand vals
    if isscalar(vals)
        vals = repmat(vals, nnz(S), 1);
    end 
    
    createdS = isempty(S);    
    
    [S(idx).(fld{iFld})] = deal(vals{:});
    
    if createdS
        S = makecol(S);
    end

end
