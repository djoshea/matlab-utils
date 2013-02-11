%% Preamble -- not to appear in userguide
hfig = figure;
set(hfig,'units','centimeters','NumberTitle','off','Name','ex12');
pos = get(hfig,'position');
set(hfig,'position',[pos(1:2),6,4]);
%% Everything below appears in userguide
plot([-1 1],rand(3,2));
hleg = legend('L = 1 m','L = 2 m','L = 3 m');
hlegc = get(hleg,'children');
set(hlegc(9),'userdata','matlabfrag:$L=\SI{1}{m}$');
set(hlegc(6),'userdata','matlabfrag:$L=\SI{2}{m}$');
set( findobj(hlegc,'string','L = 3 m'), 'userdata',...
  'matlabfrag:$L=\SI{3}{m}$');
%% The following is excluded from userguide
matlabfrag('graphics/ex12');