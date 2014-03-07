import AutoAxis.PositionType;
import AutoAxis.AnchorInfo;
clf;
R = 3;
C = 2;

p = panel();
p.pack(R,C);
p.units = 'cm';
p.margin =  [2 2 2 0.5];
p.de.margin = 0.5;
axh = nan(R,C);
au = cell(R,C);

for r = 1:R
    for c = 1:C 
    
        axh(r,c) = p(r,c).select();
        
        t = linspace(-6,6,300);
        xlim([-5 5]);
        ylim([-5 5]);

        avals = linspace(0.5, 5, 8);
        cmap = jet(numel(avals));
        for i = 1:numel(avals)
            y = avals(i)*sin(2*pi*0.5*t);
            plot(t, y, '-', 'Color', cmap(i, :), 'LineWidth', 2);
            hold on
        end
        
        axis(axh(r,c), 'off');
        
        ha = AutoAxis(axh(r,c));
       
        if r == R
            xlabel('X Label');
            ha.addAutoAxisX();
        end
        if c == 1
            ylabel('Y Label');
            ha.addAutoAxisY();
        end
        
        ha.update();
        au{r,c} = ha;
    end
end



