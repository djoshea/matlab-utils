function ptstack_cat_pad(timeDim, stackDim, inputs, catDim, varargin)

nI = numel(inputs);
ndim = max([cellfun(@ndims, inputs), catDim]);

sz = nan(nI, ndim);
for iI = 1:nI
    sz(iI, :) = TensorUtils.sizeNDims(inputs{iI}, ndim);
end

sz_pad = repmat(max(sz, [], 1), nI, 1);
sz_pad(:, catDim) = sz(:, catDim);

padded = cellvec(nI);
for iI = 1:nI
    padded{iI} = padarray(inputs{iI}, sz_pad(iI, :) - sz(iI, :), NaN, "post");
end

data = cat(catDim, padded{:});
ptstack(timeDim, stackDim, data, 'colorDim', catDim, varargin{:});

end