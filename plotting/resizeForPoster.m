a = AutoAxis();
ax = gca;

SIZE = 12;
TITLE_SIZE = 16;

a.tickFontSize = SIZE;
a.labelFontSize = SIZE;
a.titleFontSize = TITLE_SIZE;
a.scaleBarFontSize = SIZE;

ax.FontSize = 12;
ax.LabelFontSizeMultiplier = 1;
ax.TitleFontSizeMultiplier = 1;

a.update;

%%

tx = findobj(ax, 'Type', 'Text');

for i = 1:numel(tx)
    if tx(i).FontSize < SIZE
        tx(i).FontSize = SIZE;
    end
end

a.update

%%

tx = findobj(ax, 'Type', 'Text');

for i = 1:numel(tx)
    tx(i).String = strrep(tx(i).String, 'continuous_vA', 'v');
end