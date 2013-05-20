function S = assignIntoStructArray(S, fld, vals, idx)
% S = assignIntoStructArray(S, fld, vals, idx)
% for each element s in struct array S(idx), efficiently assigns
% s.(fld) = the corresponding element from vals.
%
% vals must either be a numel(S) vector or numel(S) x numel(fld)
% cell/matrix
% 
% If fld is a cellstr, assigns vals(iS, iFld) into each field in fld{:}

    if ~exist('idx', 'var')
        if isempty(S)
            % no existing struct, make it by figuring out how many vals are
            % given
%             if ~iscell(fld) || length(fld) == 1
%                 % make into vector if many fields
%                 vals = makecol(vals);
%             end
            idx = 1:size(vals, 1);
        else
            idx = 1:length(S);
        end
    end
     
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
        vals = repmat(vals, nnz(idx), numel(fld));
    elseif isvector(vals)
        if size(vals, 1) == numel(fld)
            vals = vals';
        end
        vals = repmat(vals, 1, numel(fld));
    end 

    assert(nnz(idx) == size(vals, 1) && numel(fld) == size(vals, 2), ...
        'Vals must be scalar, vector of nnz(idx), or matrix of nnz(idx) x numel(fld)');

    createdS = isempty(S);    
    
    for iFld = 1:length(fld)
        [S(idx).(fld{iFld})] = deal(vals{:, iFld});
    end
    
    if createdS
        S = makecol(S);
    end

end
