%% Preamble -- not to appear in userguide
hfig = figure;
set(hfig,'units','centimeters','NumberTitle','off','Name','ex14');
pos = get(hfig,'position');
set(hfig,'position',[pos(1:2),8,6]);
%% Everything below appears in userguide
peaks;
hs = get(gca,'children');
set(hs,'facealpha',0.4,'edgealpha',0.4);
hl=legend('legend');
set(hl,'location','northeast');
xlabel('X','userdata','matlabfrag:$\mathrm X$');
ylabel('Y','userdata','matlabfrag:$\mathbf Y$');
zlabel('Z','fontsize',12,'userdata','matlabfrag:$\mathcal Z$')
matlabfrag('graphics/ex14','renderer','opengl','dpi',720);
%% The following is excluded from userguide