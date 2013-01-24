% DIALOG_DEMO       -     A sample dialog box created using EasyGUI
%
%   S = DIALOG_DEMO   opens a dialog box created using EasyGUI. It waits
%   for the user to complete it and click "Submit", and returns the user
%   input in the structure S. If the user clicks on "Cancel" or closes the
%   window, S is [].
%
%   Note: Currently, the default values for the fields in SAMPLE_DIALOG 
%     are hard-coded, but they can be passed in as parameters to this
%     function (in a input structure, for example).

%   Copyright 2009 The MathWorks, Inc.

function out = dialog_demo
    
myGui = gui.autogui('Visible', false, 'Location', 'float');
myGui.Name = 'Parameters for function plotting';

%% Specify the widgets

% --- First panel

gui.label('Function and range');
fcnStr = gui.edittext('F(x) = ');
minX = gui.editnumber('Minimum X value');
maxX = gui.editnumber('Maximum X value');

% --- Second panel

myGui.addPanel;
gui.label('Line style');

lineWidth = gui.slider('Linewidth', [0.1 8]);
marker = gui.textmenu('Marker', {'none', 'o', '+', 'x'});
markerSize = gui.numericmenu('Marker size', [2 4 6 8 10]);
showGrid = gui.checkbox('Show grid');
spacer2 = gui.space; spacer2.Position.height = 19;
submitButton = gui.pushbutton('Submit');

% --- Third panel

myGui.addPanel;
gui.label('Images');
imageList = gui.listbox({'Images to display' '(Ctrl-click to choose several)'}, ...
                        {'clown', 'earth', 'flujet', 'mandrill'});
cancelButton = gui.pushbutton('Cancel');

%% Assign defaults
% These could be passed in as parameters

fcnStr.Value = 'sin(2*pi*x)+ cos(x)';
minX.Value = 0;
maxX.Value = 12.5;
lineWidth.Value = 2;
marker.Value = 'x';
markerSize.Value = 6;
showGrid.Value = true;
imageList.Value = {'clown', 'flujet'};

%% Make the gui visible (the Exclusive property makes the window "modal"
% i.e., mouse clicks outside the window are ignored by MATLAB).
myGui.Visible = true;
myGui.Exclusive = true;


%% Wait for input

myGui.monitor(cancelButton, submitButton);
allOK = myGui.waitForInput();

if ~allOK 
    % window was closed by user
    out = [];
    return;
end

if myGui.LastInput == cancelButton
    out = [];
else
    % user clicked on submit
    % collect the values and package into a structure    
    out.fcnStr = fcnStr.Value;
    out.minX = minX.Value;
    out.maxX = maxX.Value;
    out.showGrid = showGrid.Value;
    out.lineWidth = lineWidth.Value;
    out.markerSize = markerSize.Value;
    out.marker = marker.Value;
    out.imageList = imageList.Value;
end

delete(myGui);
