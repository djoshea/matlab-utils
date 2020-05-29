function figh = figUnique(varargin)
% figh = figUnique(name, [height width])
p = inputParser();
p.addOptional('name', '', @ischar);
p.addOptional('size', [15 15], @(x) ~ischar(x) && isvector(x)); % [w h]
p.addParameter('undock', false, @islogical);
p.addParameter('setTitle', false, @islogical);
p.parse(varargin{:});

stackFull = dbstack();
stack = rmfield(stackFull, {'file', 'line'});
if numel(stack) == 1
    % likely in cell mode, use desktop trickery to figure out where the
    % line is executing from
    doc = matlab.desktop.editor.getActive();
    [~, stack(2).name] = fileparts(doc.Filename);
    stackFull(2).name = stack(2).name;
    stackFull(2).line = doc.Selection(1);
end

hashInput.name = p.Results.name;
hashInput.stack = stack;

% hash the stack method names and call history to a unique figure value
hashVec = Matdb.DataHash(hashInput, struct('Method', 'MD5', 'Format', 'uint8'));
hash = dot(double(hashVec), 2.^(0:numel(hashVec)-1));

if ishandle(hash)
    set(0, 'CurrentFigure', hash);
    figh = gcf;
else
    figh = figure(hash);
end

if p.Results.undock
%    set(figh, 'WindowStyle', 'normal');
end

clf(figh);

name = p.Results.name;
if isempty(name)
    name = sprintf('%s:%d', stack(2).name, stackFull(2).line);
    blankTitle = true;
else
    blankTitle = false;
end
set(figh, 'NumberTitle', 'off', 'Name', ['Figure ' name]);

size = p.Results.size;
if isscalar(size)
    size = [size size];
end
if p.Results.undock || strcmp(figh.WindowStyle, 'normal');
    figSize(size, figh);
end

hold on;
if ~blankTitle && p.Results.setTitle
    t = title(name);
    set(t, 'FontWeight', 'bold', 'Interpreter', 'none');
end
box off;

end