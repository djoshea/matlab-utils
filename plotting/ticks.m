function h = ticks(xvals, y, varargin)
% h = ticks(xvals, y, varargin)

if nargin < 2
    y = 0;
end
if numel(y) < 2
    y = [y; y+1];
end

X = repmat(makerow(xvals), 2, 1);
Y = repmat(makecol(y), 1, numel(xvals));
if numel(varargin) == 0
    varargin = {'Color', 'k'};
end
h = line(X, Y, varargin{:});

