%% Preamble -- not to appear in userguide
hfig = figure;
set(hfig,'units','centimeters','NumberTitle','off','Name','ex02');
pos = get(hfig,'position');
set(hfig,'position',[pos(1:2),4,3]);
%% Everything below appears in userguide
plot(rand(2));
axis([1 2 0 1]);
xlabel('should not see this text','UserData',...
  'matlabfrag:Plays nice with \LaTeX');
matlabfrag('graphics/ex02');