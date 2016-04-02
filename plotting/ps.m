function h = ps(varargin)
% wrapper around plot that auto-squeezes its arguments

for i = 1:numel(varargin)
    if isnumeric(varargin{i})
        varargin{i} = squeeze(varargin{i});
    end
end

h = plot(varargin{:});