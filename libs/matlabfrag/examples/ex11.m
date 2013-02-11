%% Preamble -- not to appear in userguide
hfig = figure;
set(hfig,'units','centimeters','NumberTitle','off','Name','ex11');
pos = get(hfig,'position');
set(hfig,'position',[pos(1:2),6,3]);
%% Everything below appears in userguide
plot([1 exp(1)],rand(2));
hax = gca;
set(hax,'xlim',[1 exp(1)],'xtick',[1 exp(0.5) exp(1)],...
  'xticklabel',{'$e^0$','$e^{0.5}$','$e^1$'});
set(hax,'ylim',[0 1],'ytick',[0 real(exp(-i*7*pi/4)) 1],...
  'yticklabel',{'\ytick{3\pi/2}','\ytick{7\pi/4}','\ytick{2\pi}'});
%% The following is excluded from userguide
matlabfrag('graphics/ex11');