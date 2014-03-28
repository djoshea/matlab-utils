%% Display in single axis
figure(1); clf; set(gcf, 'Color', 'w');
P = peaks(40); 
C = del2(P);
surf(P,C);

hold on; axis off; axis tight;
set(gca, 'LooseInset', [ 0 0 0 0 ]);
xlabel('X');
ylabel('Y');
zlabel('Z');
tv = ThreeVector();
    
%% Multiple axes in subplot
figure(2); clf; set(gcf, 'Color', 'w');
R = 2;
C = 2;
p = panel();
p.margin = 10;
p.pack(R, C);
for r = 1:R
    for c = 1:C
        p(r,c).select();
        P = peaks(40); 
        C = del2(P);
        surf(P,C);
        colormap hot
        view([322 39]);

        hold on; axis off; axis tight;
        set(gca, 'LooseInset', [ 0 0 0 0 ]);
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
        tv.vectorLength = 1;
    end
end

return;

%% Demo save/load functionality

f = [tempname() '.fig'];
savefig(gcf, f);
close all
openfig(f);


    tv = ThreeVector(gca);