% DAQPLOT2    -   Analog data acquisition GUI with stripchart
%
%   DAQPLOT2 allows the user to configure and start analog data
%   acquisition. The acquired data is plotted in a scrolling stripchart.
%
%   DAQPLOT2 demonstrates how to use the GUI.DAQINPUT widget with the
%   GUI.STRIPCHART widget. 
%    - The GUI.DAQINPUT widget allows the user to configure and start
%      analog data acquisition. 
%    - DAQPLOT2 simply gets the data and passes it along to the
%      GUI.STRIPCHART widget. 
%
%   THIS GUI REQUIRES THE DATA ACQUISITION TOOLBOX

%   Copyright 2009 The MathWorks, Inc.

function daqplot2

myGui = gui.autogui;
daq = gui.daqinput;
chart = gui.stripchart(gca);

daq.AdaptorName = 'winsound';
daq.DeviceId = '0';
daq.Channels = 1;
daq.SampleRate = 8000;

while myGui.waitForInput()
    info = daq.Value;
    chart.update(info.data);
end
