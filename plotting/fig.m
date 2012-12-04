% produces a blank figure with everything turned off
function hf = fig(fignum)

if ~exist('fignum', 'var')
    hf = figure;
else
    hf = figure(fignum);
end
clf;
set(gca,'visible', 'off');
set(hf, 'color', [1 1 1]);
axis square;
set(gca, 'Box', 'off');




