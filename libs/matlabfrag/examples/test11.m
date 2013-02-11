hfig = figure;
set(hfig,'units','centimeters','NumberTitle','off','Name','test11');
pos = get(hfig,'position');
set(hfig,'position',[pos(1:2),6,4]);

%%
plot([-1 1],rand(6,2));
set(gca,'xtick',[]);
hleg=legend('line 1','line 2','3','4','5','6');
h6=findobj(hleg,'string','6');
set(h6,'userdata','matlabfrag:Line6');

%%
matlabfrag('graphics/test11');