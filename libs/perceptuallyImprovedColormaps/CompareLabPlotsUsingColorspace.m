%% for the spectrum below I used the RGB triplets from CIE 1964 10-deg XYZ
RGB=[0.1127         0    0.3515
     0.2350         0    0.6663
     0.3536         0    1.0000
     0.4255         0    1.0000
     0.4384         0    1.0000
     0.3888         0    1.0000
     0.2074         0    1.0000
          0         0    1.0000
          0    0.4124    1.0000
          0    0.6210    1.0000
          0    0.7573    0.8921
          0    0.8591    0.6681
          0    0.9642    0.4526
          0    1.0000    0.1603
          0    1.0000         0
          0    1.0000         0
          0    1.0000         0
          0    1.0000         0
     0.4673    1.0000         0
     0.8341    1.0000         0
     1.0000    0.9913         0
     1.0000    0.8680         0
     1.0000    0.7239         0
     1.0000    0.5506         0
     1.0000    0.3346         0
     1.0000         0         0
     1.0000         0         0
     1.0000         0         0
     1.0000         0         0
     0.9033         0         0
     0.7412         0         0
     0.5902         0         0];
 
Spectrum=interp1(linspace(1, 256, 32),RGB,[1:1:256]);
cube=pmkmp(256);
J=jet(256);

%% sRGB->Lab conversion of CubicL, jet, and Spectrum colormaps
%  requires this submission: Colorspace transforamtions
%  www.mathworks.com/matlabcentral/fileexchange/28790-colorspace-transformations

L3=colorspace('RGB->Lab',cube);
LJ=colorspace('RGB->Lab',J);
LS=colorspace('RGB->Lab',Spectrum);

%% compare L* plots for CubicL, jet, and Spectrum colormaps
%  requires this submission: Cline
%  www.mathworks.cn/matlabcentral/fileexchange/14677-cline

figure;
cline([1:1:256],L3(:,1),L3(:,1),[1:1:256],cube);
title ('L* plot for CubicL colormap','Color','k','FontSize',12);

figure;
cline([1:1:256],LJ(:,1),LJ(:,1),[1:1:256],J);
title ('L* plot for jet colormap','Color','k','FontSize',12);

figure;
cline([1:1:256],LS(:,1),LS(:,1),[1:1:256],Spectrum);
title ('L* plot for spectrum colormap','Color','k','FontSize',12);