function testAutoAxisSubplot()
    import AutoAxis.PositionType;
    import AutoAxis.AnchorInfo;
    clf;
    R = 2;
    C = 2;
    
    axh = nan(R,C);
    au = cell(R,C);

    idx = 0;
    for r = 1:R
        for c = 1:C 
            idx = idx + 1;
            axh(r,c) = subplot(R,C,idx);
            
            t = linspace(-5,5,300);
            xlim([-5 5]);
            ylim([-5 5]);

            avals = linspace(0.5, 5, 8);
            cmap = jet(numel(avals));
            for i = 1:numel(avals)
                y = avals(i)*sin(2*pi*1/2.5*t);
                plot(t, y, '-', 'Color', cmap(i, :), 'LineWidth', 2);
                hold on
            end

            axis(axh(r,c), 'off');

            ha = AutoAxis(axh(r,c));

            xlabel('X Label');
            ha.addAutoAxisX();
            ylabel('Y Label');
            ha.addAutoAxisY(); 
          
            %ha.update();
            ha.installCallbacks();
            au{r,c} = ha;
        end
    end

    AutoAxis.updateFigure();
end

function callbackFn(data)
    AutoAxis.updateFigure();
end

