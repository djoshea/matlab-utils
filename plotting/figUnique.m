function figh = figUnique(varargin)

p = inputParser();
p.addOptional('name', '', @ischar);
p.addOptional('size', [15 15], @isvector);
p.parse(varargin{:});

stack = dbstack();
stack = rmfield(stack, 'file');

% hash the stack method names and call history to a unique figure value
hashVec = DataHash(stack, struct('Method', 'MD5', 'Format', 'uint8'));
hash = dot(double(hashVec), 2.^(0:numel(hashVec)-1));

figh = figure(hash);
clf(figh);

name = p.Results.name;
if isempty(name)
    name = sprintf('%s:%d', stack(1).name, stack(1).line);
end
set(figh, 'NumberTitle', 'off', 'Name', name);

size = p.Results.size;
if isscalar(size)
    size = [size size];
end
figSize(size(1), size(2));

hold on;
t = title(name);
set(t, 'FontWeight', 'bold');
box off;

end