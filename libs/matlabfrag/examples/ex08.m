%% Preamble -- not to appear in userguide
hfig = figure;
set(hfig,'units','centimeters','NumberTitle','off','Name','ex08');
pos = get(hfig,'position');
set(hfig,'position',[pos(1:2),4,3]);
%% Everything below appears in userguide
plot(rand(2));
axis([1 2 0 1]);
xlabel('Comic sans?','FontName','Comic Sans MS');
ht = text(1,0.5,'Fixed-width');
set(ht,'FontName','FixedWidth');
%% The following is excluded from userguide
matlabfrag('graphics/ex08');