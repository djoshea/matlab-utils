% SHAREDATA_DEMO     -     A GUI that gets user input from a dialog box
%
%   SHAREDATA_DEMO   opens up sample plotting GUI. The user specifies 
%   parameters for the plot using a dialog box (SAMPLE_DIALOG); these
%   parameters are used to update the plot.
%
%   This example demonstrates how to:
%   1) Share data between a secondary gui (in this case, a dialog box) and 
%      the main gui.
%   2) Handle situations where the user cancels the dialog or closes
%      the dialog window.

%   Copyright 2009 The MathWorks, Inc.

function sharedata_demo
   
myGui = gui.autogui;

invokeDialog = gui.pushbutton('Get Parameters');
plotButton = gui.pushbutton('Update plot');
quitButton = gui.pushbutton('Exit');

params = [];

while myGui.waitForInput()
    % ---- check what button the user pressed
    
    if myGui.LastInput == quitButton
        delete(myGui);
        break;
    end
    
    if myGui.LastInput == invokeDialog
        tmpStruct = dialog_demo;
        if ~isempty(tmpStruct),
            params = tmpStruct;
        end
        continue;
    end
    
    if myGui.LastInput == plotButton && isempty(params)    
        errordlg('Please specify the parameters (by clicking on the ''Get Parameters'' button)', ...
            'Unable to plot', 'modal');
        continue;
    end
        
    % ---- try to evaluate the user-specified function
    
    try
        inlineFcn = inline(params.fcnStr);
        range = linspace(params.minX, params.maxX, 200);
        y = inlineFcn(range);
    catch ME
        errordlg(ME.message,'Unable to evaluate function','modal');
        continue;
    end
    
    % ---- plot as specified by the parameters

    nimages = numel(params.imageList) + 1;
    subplot(2,nimages,1:nimages);    
    
    hLine = plot(range,y);
    set(hLine, 'marker', params.marker, ...
               'markersize', params.markerSize, ...
               'linewidth', params.lineWidth);
    
    if params.showGrid
        grid on;
    end
    
    for i=1:length(params.imageList)
        subplot(2,nimages,nimages+i);
        data = load(params.imageList{i});
        imagesc(data.X); colormap(data.map);
        axis off; axis equal;
    end
    
end

