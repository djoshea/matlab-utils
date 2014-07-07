function showAxisBorders(figh)

if nargin < 1
    figh = gcf;
end

% create or recover overlay axis
axhOverlay = findobj(figh, 'type', 'axes', 'Tag', 'overlay');
if isempty(axhOverlay)
    axhOverlay = axes('Position', [0 0 1 1]);
    set(axhOverlay, 'Tag', 'overlay', 'Color', 'none');
end
uistack(axhOverlay, 'top');
axis(axhOverlay, [0 1 0 1]);
cla(axhOverlay);

axhList = findobj(figh, 'type', 'axes');
axhList = axhList(~strcmp(get(axhList, 'Tag'), 'overlay'));

cmap = distinguishable_colors(numel(axhList));

for i = 1:numel(axhList)
    axh = axhList(i);
    
    op = get(axh, 'OuterPosition');
    rectangle('Parent', axhOverlay, 'Position', op, 'LineWidth', 2, 'EdgeColor', cmap(i, :));
    hold(axhOverlay, 'on');
   
    p = get(axh, 'Position');
    rectangle('Parent', axhOverlay, 'Position', p, 'LineWidth', 1, 'EdgeColor', cmap(i,:));
end

hold(axhOverlay, 'off');