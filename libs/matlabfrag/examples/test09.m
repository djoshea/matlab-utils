hfig = figure;
set(hfig,'units','centimeters','NumberTitle','off','Name','test09');
pos = get(hfig,'position');
set(hfig,'position',[pos(1:2),8,6]);

%%
plot([-1 1],rand(6,2));
set(gca,'xtick',-1:0.2:1);
set(gca,'ytick',0:0.25:1);
set(gca,'xticklabel',{'-1' '' '' '' '' '0' '' '' '' '' '1' });
set(gca,'yticklabel',{'0' '' '0.5' '' '1'});
hleg=legend('line 1','line 2','3','4','5','6');
h6=findobj(hleg,'string','6');
set(h6,'userdata','matlabfrag:Line6');

%%
matlabfrag('graphics/test09');