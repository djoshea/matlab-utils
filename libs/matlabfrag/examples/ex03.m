%% Preamble -- not to appear in userguide

%% Everything below appears in userguide
hfig = figure;
plot([-1 1],rand(2));
axis([-1 1 0 1]);
set(hfig,'units','centimeters',...
  'NumberTitle','off','Name','ex03');
pos = get(hfig,'position');
set(hfig,'position',[pos(1:2),8,3]);
%% The following is excluded from userguide
matlabfrag('graphics/ex03');