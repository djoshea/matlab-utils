function testAutoAxisPanel2()
    import AutoAxis.PositionType;
    import AutoAxis.AnchorInfo;
    clf;
    R = 1;
    C = 2;

    p = OuterPanel();
    p.pack(R,C);
    p.units = 'cm';
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

            if r == R
               % p(r,c).marginbottom = 2.2; 
            end
            p(r,c).xlabel('X Label');
            ha.addAutoAxisX();
%                 
            if r == 1
            %    p(r,c).margintop = 1;
            end
            
            p(r,c).ylabel('Y Label');
                ha.addAutoAxisY();
            if c == 1
%                 p(r,c).marginleft = 2.2;
            end
            if c == C
%                 p(r,c).marginright = 1;
            end

            ha.axisMargin = [2 2 0 0];
            ha.installCallbacks();
            au{r,c} = ha;
        end
    end

    AutoAxis.updateFigure();
    
end

function callbackFn(~)
    AutoAxis.updateFigure;
end

