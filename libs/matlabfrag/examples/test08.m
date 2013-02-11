hfig = figure;
set(hfig,'units','centimeters','NumberTitle','off','Name','test08');
pos = get(hfig,'position');
set(hfig,'position',[pos(1:2),5,6]);

%%
spy;
set(gca,'xticklabel','','yticklabel','');
xlabel('');

%%
matlabfrag('graphics/test08-painters');
matlabfrag('graphics/test08-opengl','renderer','opengl');