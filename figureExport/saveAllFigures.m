function saveAllFigures()

figs = findobj('Type', 'figure');

for i = 1:numel(figs)
    n = figs(i).Name;
    figure(figs(i));
    if isempty(n)
        warning('Skipping figure %d without name', figs(i).Number);
        continue;
    end
    saveFigure;
    close(figs(i));
end