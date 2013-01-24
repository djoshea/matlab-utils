% MANUALDEMO     -     EasyGUI Example using manual layout
%
%   GUI for plotting a Lissajous curve 
%      sin(f1) vs. sin(f2 + theta)
%  
%   This example implements the same functionality as AUTODEMO, but
%   uses manual positioning of figure, axes and widgets. This explicit
%   control allows customized layout.

%   Copyright 2009 The MathWorks, Inc.

function manualdemo

% create a manualgui instead of autogui
myGui = gui.manualgui;

% The parent (myGui) has to be explicitly specified
freq1 = gui.slider('Frequency 1 (Hz)', [1 40], myGui);
freq2 = gui.slider('Frequency 2 (Hz)', [1 40], myGui);
phaseDiff = gui.numericmenu('Phase difference (degrees)', 0:30:180, myGui);

% explicitly set the size of the gui figure 
guiWidth = 560; guiHeight = 420;
movegui(myGui.UiHandle,'onscreen',[guiWidth guiHeight]);
set(myGui.UiHandle, 'Resize', 'off');

% explicitly position the widgets
freq1.Position = struct('x', 50,  'y', 20, 'width', 120);
freq2.Position = struct('x', 200, 'y', 20, 'width', 120);
phaseDiff.Position = struct('x', 350, 'y', 20, 'width', 160);

% explicitly create and position the axes as well
myAxes = axes('units', 'pixels', 'position', [80 130 400 250]);
set(myAxes,'nextplot','add');

% default values of the widgets
freq1.Value = 20;
freq2.Value = 25;
phaseDiff.Value = 90;

% sampling parameters
Fs = 500;
t = 0:(1/Fs):1;

% gui.manualgui does not provide built-in support for waitForInput()
% so we need to set it up explicitly 
myMonitor = gui.monitor(myGui.Children);

while myMonitor.waitForInput()
        
    phaseRadians = phaseDiff.Value * (pi/180);
    sig1 = sin(2*pi*t*freq1.Value);
    sig2 = sin(2*pi*t*freq2.Value + phaseRadians);
    
    axes(myAxes);
    cla;
    xlabel('sin(2 \pi f_1 t)');
    ylabel('sin(2 \pi f_2 t + \theta');
    axis equal; axis square;
    axis([-1.2 1.2 -1.2 1.2]);
    
    plot(sig1,sig2);

end

