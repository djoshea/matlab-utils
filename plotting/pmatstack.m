function pmatstack(varargin)

if numel(varargin) >= 4 && isnumeric(varargin{1}) && isnumeric(varargin{2}) ...
        && isnumeric(varargin{3}) && isnumeric(varargin{4})
    % x y z provided
    x = varargin{1};
    y = varargin{2};
    z = varargin{3};
    D = varargin{4};

    remainder = varargin(5:end);
    
    assert(numel(x) == size(D, 1));
    assert(numel(y) == size(D, 2));
    assert(numel(z) == size(D, 3)); 
else
    D = varargin{1};
    x = 1:size(D, 1);
    y = 1:size(D, 2);
    z = 1:size(D, 3);

    remainder = varargin(2:end);
end

p = inputParser();
p.addParameter("gap", 1, @isscalar);
p.KeepUnmatched = true;
p.parse(remainder{:});

sz = size(D);

if p.Results.gap > 0
    D = TensorUtils.expandAlongDims(D, 1, p.Results.gap);
end

D = TensorUtils.reshapeByConcatenatingDims(D, {[1 3] 2});

pmat(D, p.Unmatched);



    
    