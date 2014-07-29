import AutoAxis.PositionType;
import AutoAxis.AnchorInfo;
close all;

figure(1), clf, set(1, 'Color', 'w');

t = linspace(-6,6,300);
xlim([-5 5]);
ylim([-5 5]);

avals = linspace(0.5, 5, 20);
cmap = copper(numel(avals));
useOpenGL = true;
for i = 1:numel(avals)
    y = avals(i)*sin(2*pi*0.5*t);
    if useOpenGL
        patchline(t, y, 'EdgeColor', cmap(i, :), 'LineWidth', 2, 'EdgeAlpha', 0.5);
    else
        plot(t, y, '-', 'Color', cmap(i, :), 'LineWidth', 2);
    end
    hold on
end

% playing around with a dot and label

%hm = plot(5.5,4, 'o', 'MarkerSize', 20, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'none');
%ht = text(1,1, 'Anchored Label', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');

ax = AutoAxis.replaceScaleBars(gca, 'mm', 'mm');
