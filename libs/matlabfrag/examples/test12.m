%% Preamble -- not to appear in userguide
hfig = figure;
set(hfig,'units','centimeters','NumberTitle','off','Name','test12');
pos = get(hfig,'position');
set(hfig,'position',[pos(1:2),6,4]);
%% Everything below appears in userguide
y1 = 1e-6*rand(1,2);
y2 = 1e-6*rand(1,2);
x = [0 1e-3];
hax = plotyy(x,y1,x,y2);
set(hax(1),'xtick',1e-3*[0 7/32 1/2 47/64 1]);
set(hax(2),'ylim',[0 1e-6],'ytick',1e-6*[0 1/3 2/3 1],'yticklabelmode','auto');
set(hax(2),'xticklabel','');
%% The following is excluded from userguide
matlabfrag('graphics/test12');