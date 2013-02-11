%% Preamble -- not to appear in userguide
hfig = figure;
set(hfig,'units','centimeters','NumberTitle','off','Name','ex10');
pos = get(hfig,'position');
set(hfig,'position',[pos(1:2),6,5]);
%% Everything below appears in userguide
plot(rand(2));
axis([1 2 0 1]);
title(['2d matrix           ';'     weird alignment']);
xlabel({'cells';'are';'better!'});
text(2,0.5,'multiline in LaTeX','HorizontalAlignment',...
  'right','UserData',['matlabfrag:\begin{tabular}',...
  '{@{}r@{}}multiline\\in\\\LaTeX\end{tabular}']);
%% The following is excluded from userguide
matlabfrag('graphics/ex10');