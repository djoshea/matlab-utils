% BPFILTER  -         GUI demonstrating a bandpass filter
%
%   BPFILTER is a GUI (built with EasyGUI) that demonstrates the properties
%   of a simple bandpass filter. The user can adjust the properties of the
%   filter (filter order, center frequency, etc.) and see the effect on the
%   filter spectrum and input sinusoids.
%
%   THIS GUI REQUIRES THE SIGNAL PROCESSING TOOLBOX

%   Copyright 2009 The MathWorks, Inc.

function bpfilter

if ~exist('fir1','file')
    throw(MException('bpfilter:MissingFunction', ...
        'This demo requires the Signal Processing Toolbox'));
end

% gui elements
myGui = gui.autogui('Name', 'Bandpass Filter demo');
inputHz = gui.slider('Input frequency (Hz)', [500 3000]);
centerHz = gui.slider('Center of bandpass (Hz)', [500 3000]);
bandwidthHz = gui.slider('Bandwidth (Hz)', [50 1000]);
filterOrder = gui.numericmenu('Filter order', 2:3:60);

% default values
inputHz.Value = 1000;
centerHz.Value = 2000;
bandwidthHz.Value = 200;
filterOrder.Value = 20;

% sampling parameters
Fs = 8000; % Hz
t = 0:(1/Fs):0.05;
Nyquist = Fs/2;

ax1 = subplot(211);
ax2 = subplot(212);

while myGui.waitForInput
    inputsig = sin(2*pi*t*inputHz.Value);
    
    if myGui.LastInput == filterOrder
        fprintf('Filter order changed to %d\n', filterOrder.Value);
    end
        
    % create a bandpass filter of specified width and order
    frac = centerHz.Value/Nyquist;
    delta = bandwidthHz.Value/Nyquist;
    b = fir1(round(filterOrder.Value), [frac-delta frac+delta]);

    % filter the sinusoid
    outputsig = filter(b, 1, inputsig);

    % display the original and modified sinusoid
    % and bode plot of filter
    axes(ax1);
    [h,f] = freqz(b, 1, 200, Fs);
    plot(f, 20*log10(abs(h)));
    axis([0  Fs/2 -100  5]);
    line([inputHz.Value inputHz.Value], [-100 5], 'color','r');
    xlabel('Frequency (Hz)');
    ylabel('Power gain dB)');
    
    axes(ax2);
    plot(t, outputsig, 'r');
    ylim([-1 1]);
    xlabel('Time (sec'); ylabel('Amplitude');
    title('Output');            
end

