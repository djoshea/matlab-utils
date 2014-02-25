function testThreeVector()

figure(1); clf; set(gcf, 'Color', 'w');
P = peaks(40);
C = del2(P);
surf(P,C);
colormap hot
view([322 39]);

xlabel('X');
ylabel('Y');
zlabel('Z');
hold on; axis off; axis tight;
set(gca, 'LooseInset', [ 0 0 0 0 ]);

tv = ThreeVector(gca);
% tv.installCallbacks();
rotate3d on;

