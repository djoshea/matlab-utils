%% Preamble -- not to appear in userguide
hfig = figure;
set(hfig,'units','centimeters','NumberTitle','off','Name','ex05');
pos = get(hfig,'position');
set(hfig,'position',[pos(1:2),4,3]);
%% Everything below appears in userguide
plot(rand(2));
axis([1 2 0 1]);
hx = xlabel('12pt font');
set(hx,'FontSize',12);
text(1,0.5,'8pt font','FontSize',8);
%% The following is excluded from userguide
matlabfrag('graphics/ex05');