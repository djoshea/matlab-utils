function h = colorView(map)
% map is nColors x 3 x nMaps

if isa(map, 'function_handle')
    map = map(20);
end

h = image(permute(map, [3 1 2]));
ax = gca;
ax.YTick = [];
ax.TickDir = 'out';
box off;
ax.YRuler.Visible = 'off';
xlim([0.5 size(map, 1)+0.5]);

end