% AUTODEMO3     -     EasyGUI example using automatic layout and callbacks
%
%   GUI for plotting a lissajous curve 
%   (http://en.wikipedia.org/wiki/Lissajous_curve)
%      sin(f1) vs. sin(f2 + theta)
%  
%   This example builds on AUTODEMO and AUTODEMO2. It demonstrates
%   how to process all the user input using *several* callback 
%   functions. This is more efficient since various signals are 
%   recomputed only when necessary.

%   Copyright 2009 The MathWorks, Inc.

function autodemo3

% gui elements
myGui = gui.autogui;
myGui.Name = 'Lissajous figure demo';

freq1 = gui.slider('Frequency 1 (Hz)', [1 40]);
freq2 = gui.slider('Frequency 2 (Hz)', [1 40]);
phaseDiff = gui.numericmenu('Phase difference (degrees)', 0:30:180);
plotType = gui.textmenu('Lissajous plot type', {'2d-phase', '2d-comet'});

% sampling parameters and "global" parameters 
Fs = 500;
t = 0:(1/Fs):1;
sig1 = zeros(1,numel(t));
sig2 = zeros(1,numel(t));

ax1 = subplot(10,10, 1:20);
ax2 = subplot(10,10, 31:100);
set(ax2,'nextplot','add');

% callbacks, invoked whenever the Value property changes
freq1.ValueChangedFcn = @recalcSig1;
freq2.ValueChangedFcn = @recalcSig2;
phaseDiff.ValueChangedFcn = @recalcSig2;
plotType.ValueChangedFcn = @redrawPlots;

% set default values. This invokes the callbacks
% and forces calculation of sig1 and sig2.
freq1.Value = 20;
freq2.Value = 25;

    function recalcSig1(hWidget) %#ok<INUSD>
        % hWidget is the widget with the just-received input
        % we don't need this information in this demo        
        sig1 = sin(2*pi*t*freq1.Value);        
        redrawPlots(hWidget);
    end

    function recalcSig2(hWidget) %#ok<INUSD>
        phaseRadians = phaseDiff.Value * (pi/180);        
        sig2 = sin(2*pi*t*freq2.Value + phaseRadians);
        redrawPlots(hWidget);
    end
    
    function redrawPlots(hWidget) %#ok<INUSD>
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



