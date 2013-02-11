%% Preamble -- not to appear in userguide
hfig = figure;
set(hfig,'units','centimeters','NumberTitle','off','Name','test13');
pos = get(hfig,'position');
set(hfig,'position',[pos(1:2),6,4]);
%% Everything below appears in userguide
plot([0 1],rand(6,2));
set(gca,'ylim',[0 1],'xlim',[0.2 1],'xtick',0:0.25:1);
matlabfrag('graphics/test13a');
set(gca,'xticklabel',{'0.00','0.25','0.50','0.75','1'});
matlabfrag('graphics/test13b')