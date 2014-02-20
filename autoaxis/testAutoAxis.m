clf;

t = linspace(-6,6,300);
xlim([-5 5]);
ylim([-5 5]);

avals = linspace(0.5, 5, 20);
cmap = jet(numel(avals));
for i = 1:numel(avals)
    y = avals(i)*sin(2*pi*0.5*t);
    plot(t, y, '-', 'Color', cmap(i, :), 'LineWidth', 2);
    hold on
end

xlabel('X label');
ylabel('Y label');
title('Plot title');

% playing around with a dot and label

% hm = plot(3,3, 'ro', 'MarkerSize', 25, 'MarkerFaceColor', 'r');
% ht = text(1,1, 'Label', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');

% a = AutoAxis.AnchorInfo;
% a.h = ht;
% a.ha = hm;
% a.pos = AutoAxis.PositionType.Top;
% a.posa = AutoAxis.PositionType.Bottom;
% 
% a2 = AutoAxis.AnchorInfo;
% a2.h = hm;
% a2.ha = ht;
% a2.pos = AutoAxis.PositionType.HCenter;
% a2.posa = AutoAxis.PositionType.HCenter;
% 
% au.addAnchor(a);
% au.addAnchor(a2);

% [hl, ht] = au.addTickBridge('x');
% [hl, ht] = au.addTickBridge('y');

au = AutoAxis();

au.addAutoAxisY();
au.addTitle();

useAutoAxisX = true;
if useAutoAxisX
    au.addAutoAxisX();
else
    au.addTickBridge('x', 'XTick', -5:-1);
    xvals = 0:5;
    cmap = jet(numel(xvals));
    for i = 1:numel(xvals)
        x = xvals(i);
        au.addMarkerX(x, sprintf('X=%d', x), 'markerColor', cmap(i, :), 'markerSize', 0.4);
    end
    %au.axisInset(2) = 4;
    au.addXLabel();
end

axis off
au.update();
au.installCallbacks();
auVec(i) = au;

