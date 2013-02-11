hfig = figure;
set(hfig,'units','centimeters','NumberTitle','off','Name','test10');
pos = get(hfig,'position');
set(hfig,'position',[pos(1:2),6,4]);

%%
plot([-1 1],rand(6,2));
set(gca,'xtick',[-0.5 0.5]);
set(gca,'xticklabel',{'red','green'});
hleg=legend('line 1','line 2','3','4','5','6');
h6=findobj(hleg,'string','6');
set(h6,'userdata','matlabfrag:Line6');

%%
matlabfrag('graphics/test10');