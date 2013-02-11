%% Preamble -- not to appear in userguide
hfig = figure;
set(hfig,'units','centimeters','NumberTitle','off','Name','ex07');
pos = get(hfig,'position');
set(hfig,'position',[pos(1:2),4,3]);
%% Everything below appears in userguide
plot(rand(2));
axis([1 2 0 1]);
hx=xlabel('Bold font');
set(hx,'FontWeight','bold');
text(1,0.5,'Demi font','FontWeight','demi');
title('Light font','FontWeight','light');
%% The following is excluded from userguide
matlabfrag('graphics/ex07');