%% Preamble -- not to appear in userguide
hfig = figure;
set(hfig,'units','centimeters','NumberTitle','off','Name','ex09');
pos = get(hfig,'position');
set(hfig,'position',[pos(1:2),4,3]);
%% Everything below appears in userguide
plot(rand(2));
axis([1 2 0 1]);
xlabel('$x=\frac{\alpha}{\beta}$','interpreter','none');
text(1.5,0.5,'$x=\frac{\alpha}{\beta}$',...
  'interpreter','latex');
%% The following is excluded from userguide
matlabfrag('graphics/ex09');