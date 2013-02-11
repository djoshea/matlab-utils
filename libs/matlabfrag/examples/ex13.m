%% Preamble -- not to appear in userguide
hfig = figure;
set(hfig,'units','centimeters','NumberTitle','off','Name','ex13');
pos = get(hfig,'position');
set(hfig,'position',[pos(1:2),7,5]);
%% Everything below appears in userguide
[x,y,z] = peaks(20);
surf(x.*1e-3,y.*1e-3,z);
% placed inside the label, need to set xticklabelmode to manual
xlabel('x axis ($x10^{-3}$)','interpreter','latex',...
  'userdata','matlabfrag:x axis $\left(\times10^{-3}\right)$');
set(gca,'xticklabelmode','manual');
% manually placed as a text object:
ylabel('ylabel');
set(gca,'yticklabelmode','manual');
text(-10e-3,0,-10,'$x10^{-3}$','interpreter','latex',...
  'userdata','matlabfrag:$\times10^{-3}$');
%% The following is excluded from userguide
matlabfrag('graphics/ex13');