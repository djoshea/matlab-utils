%% Preamble -- not to appear in userguide
hfig(1) = figure;
set(hfig(1),'units','centimeters','NumberTitle','off','Name','test16-fig1');
pos = get(hfig(1),'position');
set(hfig(1),'position',[pos(1:2),6,4]);
hfig(2) = figure;
set(hfig(2),'units','centimeters','NumberTitle','off','Name','test16-fig2');
pos = get(hfig(2),'position');
set(hfig(2),'position',[pos(1:2),6,4]);
%% Everything below appears in userguide
hax(1) = axes('parent',hfig(1));
hax(2) = axes('parent',hfig(2));
plot(hax(1),[0 1],1e-3*rand(6,2));
plot(hax(2),[0 1],1e-6*rand(6,2));
set(hax(1),'ylim',1e-3*[0 1]);
set(hax(2),'ylim',1e-6*[0 1]);
xlabel(hax(1),'x label');xlabel(hax(2),'x label');
ylabel(hax(1),'y label');ylabel(hax(2),'y label');
matlabfrag('graphics/test16-fig1','handle',hfig(1));
matlabfrag('graphics/test16-fig2','handle',hfig(2));