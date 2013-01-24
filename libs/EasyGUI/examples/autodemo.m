% AUTODEMO     -     EasyGUI example using automatic layout
%
%   GUI for plotting a Lissajous curve 
%   (http://en.wikipedia.org/wiki/Lissajous_curve)
%      sin(f1) vs. sin(f2 + theta)
%  
%   This example demonstrates how to:
%   1) Create a GUI with automatic layout of widgets
%   2) Combine the GUI with MATLAB plotting commands, and
%   3) Process user input in a WHILE loop.

%   Copyright 2009 The MathWorks, Inc.
   
function autodemo

% gui elements
myGui = gui.autogui;
myGui.Name = 'Lissajous figure demo';

freq1 = gui.slider('Frequency 1 (Hz)', [1 40]);
freq2 = gui.slider('Frequency 2 (Hz)', [1 40]);
phaseDiff = gui.numericmenu('Phase difference (degrees)', 0:30:180);
plotType = gui.textmenu('Lissajous plot type', {'2d-phase', '2d-comet'});

% default values
freq1.Value = 20;
freq2.Value = 25;

% sampling parameters
Fs = 500;
t = 0:(1/Fs):1;

ax1 = subplot(10,10, 1:20);
ax2 = subplot(10,10, 31:100);
set(ax2,'nextplot','add');

while myGui.waitForInput
    phaseRadians = phaseDiff.Value * (pi/180);
    sig1 = sin(2*pi*t*freq1.Value);
    sig2 = sin(2*pi*t*freq2.Value + phaseRadians);
            
    axes(ax1);
    plot(t,sig1,'b',t,sig2,'r');
    
    axes(ax2);
    cla;
    xlabel('sin(2 \pi f_1 t)');
    ylabel('sin(2 \pi f_2 t + \theta');
    axis equal; axis square;
    axis([-1.2 1.2 -1.2 1.2]);
    
    switch plotType.Value
        case '2d-phase'
            plot(sig1,sig2);
        case '2d-comet'            
            comet(sig1,sig2);
    end

end

