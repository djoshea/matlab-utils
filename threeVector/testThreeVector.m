function testThreeVector()

    % single axis
    figure(1); clf; set(gcf, 'Color', 'w', Visible=true);
    demoPlot();
    ThreeVector();
    
%     % multiple axes in subplot
%     figure(2); clf; set(gcf, 'Color', 'w');
%     R = 2;
%     C = 2;
%     p = panel();
%     p.margin = 10;
%     p.pack(R, C);
%     for r = 1:R
%         for c = 1:C
%             p(r,c).select();
%             demoPlot();
%             ThreeVector(gca);
%         end
%     end
% 
%     % test save/load functionality
%     f = [tempname() '.fig'];
%     savefig(gcf, f);
%     close(2)
%     openfig(f);
end


function tv = demoPlot()
    P = peaks(40);
    C = del2(P);or i
    h = surf(P,C);
    set(h, 'EdgeColor', 'none');
    shading interp
    colormap hot
    view([322 39]);

    hold on; 
    axis off; 
    axis tight;
    set(gca, 'LooseInset', [ 0 0 0 0 ]);
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    axis vis3d;
end

