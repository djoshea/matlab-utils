% RLC_CIRCUIT  -         GUI demonstrating RLC circuit response
%
%   RLC_CIRCUIT is a GUI (built with EasyGUI) that demonstrates the
%   response of a RLC (series) circuit. The user can adjust R, L and C and
%   see the effect on circuit response and on an input sinusoid.
%
%   This example demonstrates how to create a "virtual lab" with:
%    a) an image of a circuit layout (here, the RLC series circuit)
%    b) adjustable circuit parameters, and
%    c) normal MATLAB commands for circuit simulation and plotting
%
%   This GUI requires the Control System Toolbox and the Signal
%   Processing Toolbox

%   Copyright 2009 The MathWorks, Inc.

function rlc_circuit

if ~(exist('tf','file') && exist('freqs', 'file'))
    throw(MException('rlc_circuit:MissingFunction', ...
        'This demo requires the Control System and Signal Processing Toolboxes'));
end

myGui = gui.autogui;
myGui.Location = 'right';
myGui.BackgroundColor = [.7 .9 .7];
myGui.Position.width = 600;
myGui.Position.height = 700;

movegui(myGui.UiHandle, 'onscreen');

inputFreq = gui.slider('Input Frequency (Hz)', [0.1 10]);
R = gui.slider('Resistance R (Ohms)', [0 2]);
L = gui.slider('Inductance L (Henrys)', [0 1]);
C = gui.slider('Capacitance C (Farads)', [0 1]);

% Default values
inputFreq.Value = 1.5;
R.Value = 0.01;
L.Value = 0.01;
C.Value = 0.1;

ax1 = subplot(3,1,1);
[img,cmap]=imread('rlc_circuit2.jpg');
imshow(img, cmap, 'parent', ax1);
Fs = 100; % Hertz

while myGui.waitForInput
    % specify transfer function
    num = 1;
    den = [L.Value*C.Value R.Value*C.Value 1]; % [s^2 s 1]

    % Requires Control System Toolbox
    sys = tf(num, den);
    
    t = 0:(1/Fs):10;
    u = sin(2*pi*inputFreq.Value*t);

    subplot(3,1,2);
    y = lsim(sys,u,t);
    % ignore the first 200 points (transient)
    pts = 200:length(t);
    plot(t(pts),u(pts),t(pts),y(pts));
    legend('Input', 'Output', 'Location', 'Northeast');
    xlabel('time');
    axis tight;

    resonantFreq = 1/(2*pi*sqrt(L.Value*C.Value)); % in Hertz

    subplot(3,1,3);
    f = linspace(0,10,400);
    [h,w] = freqs(num,den,2*pi*f);    
    plot(f,20*log10(abs(h)));
    xlabel('Frequency (Hz)');
    ylabel('Log magnitude response (dB)');
    ylims = get(gca,'ylim');
    line([inputFreq.Value inputFreq.Value], ylims, 'color','r');
    axis tight;
    
    title(sprintf('R = %.2f \\Omega, L=%.2fH, C = %.2fF,   input = %.1f Hz', ...
        R.Value, L.Value, C.Value, inputFreq.Value));
end


