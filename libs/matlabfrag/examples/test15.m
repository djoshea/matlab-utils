%% Preamble -- not to appear in userguide
hfig = figure;
set(hfig,'units','centimeters','NumberTitle','off','Name','test15');
pos = get(hfig,'position');
set(hfig,'position',[pos(1:2),32,16]);
%% Everything below appears in userguide
plot([0 1],rand(6,2));
matlabfrag('graphics/test15');