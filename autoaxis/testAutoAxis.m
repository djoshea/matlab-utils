import AutoAxis.PositionType;
import AutoAxis.AnchorInfo;
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

% playing around with a dot and label

hm = plot(5.5,4, 'o', 'MarkerSize', 20, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'none');
ht = text(1,1, 'Anchored Label', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');

au = AutoAxis();

au.addAnchor(AnchorInfo(ht, PositionType.Top, hm, PositionType.Bottom));
au.addAnchor(AnchorInfo(ht, PositionType.HCenter, hm, PositionType.HCenter));

ylabel('Y Label');
au.addAutoAxisY();
%au.addTicklessLabels('y', 'tick', -5:5);
au.addTitle('Plot Title');

useAutoAxisX = false;
if useAutoAxisX
    au.addAutoAxisX();
else
    au.addTickBridge('x', 'tick', -5:-3);
    xvals = 0:3;
    cmap = jet(numel(xvals));
    for i = 1:numel(xvals)
        x = xvals(i);
        au.addMarkerX(x, sprintf('X=%d', x), 'markerColor', cmap(i, :), ...
            'markerSize', 0.4, 'interval', [x-0.3 x+0.3]);
    end
    
    au.addIntervalX([-2 -1], 'Interval', ...
        'errorInterval', [-2.25 -0.75], 'Color', 'g', 'thickness', 0.4);
    
    %au.axisInset(2) = 4;
    au.xUnits = 'ms';
    au.addAutoScaleBarX();
    au.addXLabel('X Label');
    au.yUnits = 'Hz';
    au.addAutoScaleBarY();
    au.axisInset(3) = 2;
end


axis off
au.update();
au.installCallbacks();
auVec(i) = au;

