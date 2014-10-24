function h = titleFromFigureName(varargin)

p = inputParser();
p.addOptional('axh', gca, @ishandle);
p.KeepUnmatched = true;
p.parse(varargin{:});

axh = p.Results.axh;
figh = get(axh, 'Parent');
name = get(figh, 'Name');

h = title(axh, name);
set(h, p.Unmatched);

end