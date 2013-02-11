%% Preamble -- not to appear in userguide
hfig = figure;
set(hfig,'units','centimeters','NumberTitle','off','Name','test14');
pos = get(hfig,'position');
set(hfig,'position',[pos(1:2),6,4]);
%% Everything below appears in userguide
plot([0 1],rand(6,2));
set(gca,'ylim',[0 1],'xlim',[0 1],'xtick',0:0.2:1,'xticklabel','0|0.2||0.6\ |0.8|Unity');
matlabfrag('graphics/test14');