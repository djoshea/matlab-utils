% DAQFFT    -   Analog data acquisition GUI with analysis and visualization
%
%   DAQFFT demonstrates how to use the GUI.DAQINPUT widget in combination
%   with data analysis and visualization functions. The acquired data is
%   plotted in several ways:  
%     - as a stripchart.
%     - as a simple FFT
%     - as a scrolling "waterfall" of the spectrum
%   In addition, samples that are larger than an adjustable threshold 
%   are marked by red asterisks. 
%
%   THIS GUI REQUIRES THE DATA ACQUISITION TOOLBOX

%   Copyright 2009 The MathWorks, Inc.

function daqfft

% --- create the gui

myGui = gui.autogui;
ax1 = subplot(311);
ax2 = subplot(312);
ax3 = subplot(313);

daq = gui.daqinput;
spacer = gui.space; spacer.Position.height = 20;
detectPoints = gui.textmenu('Detect points:', {'yes', 'no'});
detectPoints.LabelLocation = 'left';
detectionThreshold = gui.slider('Detection threshold', [0 1]);
showGrid = gui.checkbox('Show grid');
chart = gui.stripchart(ax1);

% --- initialize the parameters
daq.AdaptorName = 'winsound';
daq.DeviceId = '0';
daq.Channels = 1;
daq.SampleRate = 8000;
daq.BufferSize = 1024;
daq.ValueChangedFcn = @processInput;

showGrid.Value = true;
detectPoints.Value = 'yes';
detectionThreshold.Value = 0.2;

% --- initialize variables used for plotting
fftHistory = zeros(512,10); 
fftHistoryIndex=1;

hold(ax1,'on');
detectedPoints = plot(nan,nan,'r*','parent',ax1,'markersize',4);

%% ---------------------
   % processInput is a nested function, so it has access to
   % all the variables declared in the top-level (myGui, daq, etc.)

    function processInput(hWidget) %#ok<INUSD>
        d = daq.Value;

        % update the stripchart
        chart.update(d.time, d.data); 
        if strcmp(detectPoints.Value, 'yes')
            indices = find(abs(chart.Y) > detectionThreshold.Value);
            set(detectedPoints, 'xdata', chart.X(indices), 'ydata', chart.Y(indices));
        end        
        ylim(ax1, [-1 1]);
        xlabel('time (sec)'); ylabel('Amplitude');
        
        % Plot the fft
        Fy = fft(d.data);
        Fypos = 20*log10( abs(Fy(1: floor(numel(d.data)/2))) );        
        plot(Fypos, 'parent', ax2);
        axis(ax2, [1 512 -50 80]);
        if showGrid.Value
            grid(ax2, 'on');
        else
            grid(ax2, 'off');
        end
        xlabel('Frequency (Hz)'); ylabel('Power (dB');
        
        % Plot spectrum as a 2-d "waterfall" 
        fftHistory = [fftHistory(:,2:10) Fypos(:)];
        imagesc(fftHistory.', 'parent', ax3); axis(ax3, 'xy');
        xlabel('Frequency (Hz)'); 
    end
   
end

