% AUTODEMO2     -     EasyGUI example using automatic layout and callbacks
%
%   GUI for plotting a Lissajous curve 
%   (http://en.wikipedia.org/wiki/Lissajous_curve)
%      sin(f1) vs. sin(f2 + theta)
%  
%   This example builds on AUTODEMO. It demonstrates how to process all 
%   the user input using a callback function. This allows the function 
%   to create the GUI and return to the command line right away.

%   Copyright 2009 The MathWorks, Inc.

function autodemo2

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

myGui.ValueChangedFcn = @processInput;

%% ----------------------------------------------------
     % Note: 
     % a) the code in processInput is identical to that in
     %    the while loop of LISSAJOUS
     % b) processInput is a nested function, so it has access to
     %    all the variables declared in the top-level (freq1, freq1,
     %    phaseDiff, etc.)
     
    function processInput(hWidget) %#ok<INUSD>
        % hWidget is the widget with the just-received input
        % we don't need this information in this demo
        
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
    
end



