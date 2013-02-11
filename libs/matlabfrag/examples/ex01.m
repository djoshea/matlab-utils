%% Preamble -- not to appear in userguide
hfig = figure;
set(hfig,'units','centimeters','NumberTitle','off','Name','ex01');
pos = get(hfig,'position');
set(hfig,'position',[pos(1:2),4,3]);
%% Everything below appears in userguide
hfig = figure(gcf);
plot(rand(2));
axis([1 2 0 1]);
matlabfrag('graphics/ex01-1');
matlabfrag('graphics/ex01-2','epspad',[10,10,10,10],...
  'handle',hfig);