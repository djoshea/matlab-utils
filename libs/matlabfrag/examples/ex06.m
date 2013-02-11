%% Preamble -- not to appear in userguide
hfig = figure;
set(hfig,'units','centimeters','NumberTitle','off','Name','ex06');
pos = get(hfig,'position');
set(hfig,'position',[pos(1:2),4,3]);
%% Everything below appears in userguide
plot(rand(2));
axis([1 2 0 1]);
xlabel('Italic font','FontAngle','italic');
ht = text(1,0.5,'Oblique font');
set(ht,'FontAngle','oblique');
%% The following is excluded from userguide
matlabfrag('graphics/ex06');