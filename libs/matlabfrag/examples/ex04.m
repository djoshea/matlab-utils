%% Preamble -- not to appear in userguide
hfig = figure;
set(hfig,'units','centimeters','NumberTitle','off','Name','ex04');
pos = get(hfig,'position');
set(hfig,'position',[pos(1:2),4,3]);
%% Everything below appears in userguide
plot(rand(2));
axis([1 2 0 1]);
xlabel('Red text!','color',[1 0 0]);
ht = text(1,0.5,'Green text!');
set(ht,'color',[0 1 0]);
%% The following is excluded from userguide
matlabfrag('graphics/ex04');