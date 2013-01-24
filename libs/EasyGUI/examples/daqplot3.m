% DAQPLOT3    -   Asychronous analog data acquisition GUI with stripchart
%
%   DAQPLOT3 allows the user to configure and start analog data
%   acquisition. The acquired data is plotted in a scrolling stripchart.
%   DAQPLOT3 returns control the command line right away, so the
%   user is able to invoke other MATLAB commands.
%
%   DAQPLOT3 builds on DAQPLOT and DAQPLOT2. It demonstrates how to use the
%   GUI.DAQINPUT widget in an asynchronous (i.e., non-blocking) manner.  
%   This is achieved by processing the input in a callback function rather
%   than a while loop.
%
%   THIS GUI REQUIRES THE DATA ACQUISITION TOOLBOX

%   Copyright 2009 The MathWorks, Inc.

function daqplot3

myGui = gui.autogui;
daq = gui.daqinput;
chart = gui.stripchart(gca);

daq.AdaptorName = 'winsound';
daq.DeviceId = '0';
daq.Channels = 1;
daq.SampleRate = 8000;

% We could also do this:
%   myGui.ValueChangedFcn = @processInput;
% but if myGui has other input widgets the chart would be updated 
% needlessly. It is more efficient to set ValueChangedFcn 
% on the widget itself. 

daq.ValueChangedFcn = @processInput;


%% ---------------------
   % processInput is a nested function, so it has access to
   % all the variables declared in the top-level (myGui, daq, etc.)

    function processInput(hWidget) %#ok<INUSD>
        info = daq.Value;
        chart.update(info.data);
    end
   
end

