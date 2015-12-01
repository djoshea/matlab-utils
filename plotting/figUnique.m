function figh = figUnique(varargin)
% figh = figUnique(name, [height width])
p = inputParser();
p.addOptional('name', '', @ischar);
p.addOptional('size', [15 15], @isvector);
p.parse(varargin{:});

stack = dbstack();
stack = rmfield(stack, 'file');
if numel(stack) == 1
    % likely in cell mode, use desktop trickery to figure out where the
    % line is executing from
    doc = matlab.desktop.editor.getActive();
    [~, stack(2).name] = fileparts(doc.Filename);
    stack(2).line = doc.Selection(1);
end

hashInput.name = p.Results.name;
hashInput.stack = stack;

% hash the stack method names and call history to a unique figure value
hashVec = DataHash(hashInput, struct('Method', 'MD5', 'Format', 'uint8'));
hash = dot(double(hashVec), 2.^(0:numel(hashVec)-1));

figh = figure(hash);

clf(figh);

name = p.Results.name;
if isempty(name)
    name = sprintf('%s:%d', stack(2).name, stack(2).line);
    blankTitle = true;
else
    blankTitle = false;
end
set(figh, 'NumberTitle', 'off', 'Name', name);

size = p.Results.size;
if isscalar(size)
    size = [size size];
end
figSize(figh, size(1), size(2));

hold on;
if ~blankTitle
    t = title(name);
    set(t, 'FontWeight', 'bold', 'Interpreter', 'none');
end
box off;

end