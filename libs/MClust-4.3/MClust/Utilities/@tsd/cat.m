function tsout = cat(varargin)

% tsout = cat(tsA, tsB, ...)
%
% concatenates the sequences of tsds
% checks to make sure sizes match
% raises an error if endtime(tsN) > starttime(tsN+1)

nTSD = length(varargin);

assert(nTSD>=2, 'Cannot concatenate < 2 tsds.');
assert(isa(varargin{1},'tsd'), 'Initial tsd not a tsd.');

for iTSD = 2:nTSD
    assert(varargin{iTSD}.starttime > varargin{iTSD-1}.endtime, 'times do not match.  Cannot concatenate.  Try merging.');
end

T = varargin{1}.range;
D = varargin{1}.data;

for iTSD = 2:nTSD
    T = cat(1, T, varargin{iTSD}.range);
    D = cat(1, D, varargin{iTSD}.data);    
end

tsout = tsd(T, D);

