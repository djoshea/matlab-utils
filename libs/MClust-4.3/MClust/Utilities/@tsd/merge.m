function tsout = merge(varargin)

% tsout = merge(tsA, tsB, ...)
%
% merges the sequences of tsds
% checks to make sure sizes match

nTSD = length(varargin);

assert(nTSD>=2, 'Cannot concatenate < 2 tsds.');
assert(isa(varargin{1},'tsd'), 'Initial tsd not a tsd.');

T = varargin{1}.range;
D = varargin{1}.data;

for iTSD = 2:nTSD
    T = cat(1, T, varargin{iTSD}.range);
    D = cat(1, D, varargin{iTSD}.data);    
end

[T,order] = sort(T);
D = selectalongfirstdimension(D, order);

tsout = tsd(T, D);

