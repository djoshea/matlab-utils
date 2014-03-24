function testAutoAxisSubplot()
    import AutoAxis.PositionType;
    import AutoAxis.AnchorInfo;
    clf;
    R = 3;
    C = 3;

    p = panel();
    p.pack(R,C);
    p.units = 'cm';
    p.margin = [2.2 2.2 1 1];
    p.de.margin = 0.4;
    p.setCallback(@callbackFn);

    axh = nan(R,C);
    au = cell(R,C);

    for r = 1:R
        for c = 1:C 

            axh(r,c) = p(r,c).select();

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

            % [left bottom right top]
            %ha.axisInset = [0 0 0 0];
            
            if r == R
                p(r,c).xlabel('X Label');
                ha.addAutoAxisX();
                p(r,c).marginbottom = 2.2;
            end
            if r == 1
                p(r,c).margintop = 1;
            end
            if c == 1
                p(r,c).ylabel('Y Label');
                ha.addAutoAxisY();
                
                p(r,c).marginleft = 2.2;
            end
            if c == C
                p(r,c).marginright = 1;
            end

            %ha.update();
            %ha.installCallbacks();
            au{r,c} = ha;
        end
    end

    AutoAxis.updateFigure();
    
end

function callbackFn(data)
    AutoAxis.updateFigure;
end

