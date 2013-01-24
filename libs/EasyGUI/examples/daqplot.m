% DAQPLOT     -   Analog data acquisition GUI
%
%   DAQPLOT is a simple GUI that demonstrates the GUI.DAQINPUT widget.
%   This widget allows the user to configure and start analog data
%   acquisition. The data is plotted as it is aquired.
%
%   THIS GUI REQUIRES THE DATA ACQUISITION TOOLBOX

%   Copyright 2009 The MathWorks, Inc.

function daqplot

myGui = gui.autogui;
daq = gui.daqinput;

daq.AdaptorName = 'winsound';
daq.DeviceId = '0';
daq.Channels = 1;
daq.SampleRate = 8000;

while myGui.waitForInput()
    info = daq.Value;
    plot(info.data);
end
