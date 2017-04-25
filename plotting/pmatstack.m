function pmatstack(varargin)

if numel(varargin) >= 4 && isnumeric(varargin{1}) && isnumeric(varargin{2}) ...
        && isnumeric(varargin{3}) && isnumeric(varargin{4})
    % x y z provided
    x = varargin{1};
    y = varargin{2};
    z = varargin{3};
    D = varargin{4};
    
    assert(numel(x) == size(D, 1));
    assert(numel(y) == size(D, 2));
    assert(numel(z) == size(D, 3)); 
else
    D = varargin{1};
    x = 1:size(D, 1);
    y = 1:size(D, 2);
    z = 1:size(D, 3);
end

sz = size(D);

D = TensorUtils.expandAlongDims(D, 1, 1);

D = TensorUtils.reshapeByConcatenatingDims(D, {[1 3] 2});

pmat(D);



    
    