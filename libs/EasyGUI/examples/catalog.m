% CATALOG     -     Catalog of EasyGUI widgets
%
%   CATALOG shows a list of the available EasyGUI widgets. To create
%   a widget (e.g., gui.listbox), click on the corresponding entry.
%   The widget's Value property will be printed at the MATLAB command 
%   prompt. 
%  
%   This GUI is itself written using EasyGUI.

%   Copyright 2009 The MathWorks, Inc.

function catalog

myGui = gui.autogui('Location', 'float');
myGui.Name = 'A catalog of gui widgets';

gui.label('Select a widget');
widgetTypes = {
'gui.checkbox' 
'gui.edittext' 
'gui.editnumber' 
'gui.listbox' 
'gui.textmenu' 
'gui.numericmenu' 
'gui.slider' 
'gui.pushbutton' 
'gui.togglebutton' 
'gui.label' 
'gui.daqinput' 
};


widgetType = gui.listbox('', widgetTypes); 
widgetType.AllowMultipleSelections = false;
widgetType.Position.height = 180;
helpButton = gui.pushbutton('Help');

myGui.addPanel;
widgetTitle = gui.label('');

myWidget = [];
widgetType.ValueChangedFcn = @processInputs;
helpButton.ValueChangedFcn = @showHelp;

widgetType.Value = 'gui.checkbox';

    function processInputs(ignore) %#ok<INUSD>
        delete(myWidget);
        classname = widgetType.Value;
        myWidget = feval(classname);
        helpButton.Label = ['doc ' classname];
        myWidget.ValueChangedFcn = @showValue;
        widgetTitle.Value = classname;
        disp(classname);
    end

    function showValue(hWidget)
        classname = widgetType.Value;
        disp(hWidget.Value)
    end
    
    function showHelp(ignore) %#ok<INUSD>
        classname = widgetType.Value;
        doc(classname);
    end
    
end

