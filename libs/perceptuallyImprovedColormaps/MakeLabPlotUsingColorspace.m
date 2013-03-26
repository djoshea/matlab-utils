%% sRGB->Lab conversion of CubicL 
%  requires this submission: Colorspace transforamtions
%  www.mathworks.com/matlabcentral/fileexchange/28790-colorspace-transformations

cube=pmkmp(256);
L3=colorspace('RGB->Lab',cube);

%% %%  L*, a/*, and b* plots for CubicL
plot(1:1:256,L3(:,1),'k');
hold
plot(1:1:256,L3(:,2),'r');
plot(1:1:256,L3(:,3),'b');
title ('L* a* b* plots for CubicL colormap','Color','k','FontSize',14);