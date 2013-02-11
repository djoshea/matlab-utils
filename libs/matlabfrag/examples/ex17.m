%% Preamble -- not to appear in userguide
hfig = figure;
set(hfig,'units','centimeters','NumberTitle','off','Name','ex17');
pos = get(hfig,'position');
set(hfig,'position',[pos(1:2),12,12]);
%% Everything below appears in userguide
subplot(2,2,1),plot([-1e-3 1e-3],1e-3*rand(2));
axis([-1e-3 1e-3 0 1e-3]);
set(gca,'xaxislocation','bottom','yaxislocation','left');
%
subplot(2,2,2),plot([-1e-3 1e-3],1e-3*rand(2));
axis([-1e-3 1e-3 0 1e-3]);
set(gca,'xaxislocation','top','yaxislocation','left');
%
subplot(2,2,3),plot([-1e-3 1e-3],1e-3*rand(2));
axis([-1e-3 1e-3 0 1e-3]);
set(gca,'xaxislocation','bottom','yaxislocation','right');
%
subplot(2,2,4),plot([-1e-3 1e-3],1e-3*rand(2));
axis([-1e-3 1e-3 0 1e-3]);
set(gca,'xaxislocation','top','yaxislocation','right');
%% The following is excluded from userguide
matlabfrag('graphics/ex17');