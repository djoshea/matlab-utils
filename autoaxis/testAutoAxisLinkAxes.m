
clf;
a1 = subplot(2,1,1);
ylim([-10 10]);
AutoAxis.replace(a1);
a2 = subplot(2,1,2);
AutoAxis.replace(a2);

linkaxes([a1 a2], 'xy');
AutoAxis.updateFigure;

