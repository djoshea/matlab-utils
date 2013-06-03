function vec = makeVectorAlongDim(vec, dim)
% rowVec = makeRow(vec)
% if it's a vector, rotate to row vector, else do nothing
    
    assert(isvectorHighD(vec), 'vec must be a vector');

    newSz = ones(1, max(2, dim));
    newSz(dim) = numel(vec);
    vec = reshape(vec, newSz);

end
        
function tf = isvectorHighD(vec)
    sz = size(vec);
    tf = nnz(sz ~= 1) == 1 && ~any(sz == 0);
end

