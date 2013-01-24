% guiGetDaqInputParams
%  S = guiGetDaqInputParams() shows a dialog box that allows the user to 
%      specify the configuration for analog data acquisition. 
%  
%  THIS IS A HELPER FUNCTION FOR THE GUI.DAQINPUT CLASS. 

%  S = guiGetDaqInputParams() shows a dialog box that allows the user to 
%      specify the configuration for analog data acquisition. It returns a
%      structure S with the following fields:
%         adaptor
%         boardId 
%         channelType
%         channels 
%         sampleRate 
%      S is [] if (a) the user cancelled the dialog box, (b) closed it, 
%      or (c) the dialog box is not completely filled out. 
%      
%  S = guiGetDaqInputParams(D) uses the struct D as the default values for
%      the fields of the dialog box. D should have the same fields as S.

%   Copyright 2009 The MathWorks, Inc.

function out = guiGetDaqInputParams(defaultConfig)

if nargin == 0
    defaultConfig = [];
else
    if ~isstruct(defaultConfig)
        error('defaultConfig should be a struct');
    end
end

myGui = gui.autogui('Visible', false, 'Location', 'float');
myGui.Name = 'Configure analog input';
myGui.PanelWidth = 300;

% create widgets (with initial dummy values)
myAdaptor = gui.textmenu('Adaptor', {' '}, myGui);
myAdaptor.LabelLocation = 'left';
myAdaptor.ValueChangedFcn = @adaptorCallback;

myBoardId = gui.textmenu('Board ID', {' '}, myGui);
myBoardId.LabelLocation = 'left';
myBoardId.Enable = false;
myBoardId.ValueChangedFcn = @boardIdCallback;

myChannelType = gui.textmenu('Analog channel type', {' '}, myGui);
myChannelType.LabelLocation = 'left';
myChannelType.Enable = false;
myChannelType.ValueChangedFcn = @channelTypeCallback;

myChannels = gui.listbox({'Analog channels', '(Ctrl+Click for multiple selections)'}, {' '}, myGui);
myChannels.Value = [];
myChannels.LabelLocation = 'left';
myChannels.Position.height = 60;
myChannels.Enable = false;

mySampleRate = gui.editnumber('Sample rate (Hz)', myGui);
mySampleRate.LabelLocation = 'left';
mySampleRate.Enable = false;
mySampleRate.ValueChangedFcn = @sampleRateCallback;

gui.label('', myGui); %#ok<NASGU>

myButtonGroup = gui.group('righttoleft', myGui);
myButtonGroup.BorderType = 'none';
myButtonGroup.Position.width = 300;
myCancelBtn = gui.pushbutton('Cancel', myButtonGroup);
myCancelBtn.Position.width = 100;
mySubmitBtn = gui.pushbutton('Submit', myButtonGroup);
mySubmitBtn.Position.width = 100;

myGui.Visible = true;
myGui.Exclusive = true;

myAnalogInputObj = [];
myAnalogInputInfo = [];

initializeFields(defaultConfig);
myGui.monitor(myButtonGroup);
allOk = myGui.waitForInput();
if ~allOk || myGui.LastInput == myCancelBtn
    % window was closed by user or user hit cancel
    out = [];
else
    out.adaptor = myAdaptor.Value;
    out.boardId = myBoardId.Value;
    out.channelType = myChannelType.Value;
    out.channels = str2double(myChannels.Value);
    out.sampleRate = mySampleRate.Value;
    
    if all(isspace(out.boardId)) || ...
       all(isspace(out.channelType)) || ...
       isempty(out.channels) || ...
       out.sampleRate < 1
      out = [];
    end
end

if isvalid(myGui)
    delete(myGui);
end

if isa(myAnalogInputObj, 'analoginput') && isvalid(myAnalogInputObj)
    delete(myAnalogInputObj);
end

%%
    function initializeFields(s)        
        daqmex;
        adaptorList = daq.engine.getadaptors();
        if isempty(adaptorList)
            adaptorList = {};
        end
        adaptorList{end+1} = 'Scan for others ...';       
        
        if isfield(s,'adaptor') && ischar(s.adaptor) && ~isempty(s.adaptor)
            if isempty(strmatch(s.adaptor, adaptorList, 'exact'))
                adaptorList = {s.adaptor, adaptorList{:}};
            end
            defaultAdaptor = s.adaptor;
        else
            defaultAdaptor = adaptorList{1};
        end
        
        myAdaptor.MenuItems = adaptorList;
        % Set the widget values. On each assignment, the callbacks
        % will try to populate subsequent widgets. In case of error, the 
        % subsequent widgets are set to null values (already-made
        % assignments are not unwound).        
        try
            myAdaptor.Value = defaultAdaptor; 
            if isfield(s, 'boardId')
                myBoardId.Value = s.boardId;
            end
            if isfield(s, 'channelType')
                myChannelType.Value = s.channelType;
            end
            if isfield(s, 'channels')
                myChannels.Value = cellstr(num2str(s.channels(:)));
            end
            if isfield(s, 'sampleRate')
                mySampleRate.Value = s.sampleRate;
            end
        catch  %#ok<CTCH>
            % nothing to do in case of error 
        end
    end

%%
    function adaptorCallback(h) %#ok<INUSD>
        if strcmp(myAdaptor.Value, 'Scan for others ...')
            tmpMsg = msgbox('Scanning for data acquisition hardware ...', 'Find adaptors');
            info = daqhwinfo();
            if ishandle(tmpMsg)
                delete(tmpMsg);
            end
           myAdaptor.MenuItems = info.InstalledAdaptors;
           myAdaptor.Value = info.InstalledAdaptors{1};
        end
        
        try
            info = daqhwinfo(myAdaptor.Value);
        catch  %#ok<CTCH>
            info.InstalledBoardIds = [];
        end
        
        if numel(info.InstalledBoardIds) == 0
            myBoardId.MenuItems = {' '};
            myBoardId.Value = ' ';
            myBoardId.Enable = false;
        else
            myBoardId.MenuItems = info.InstalledBoardIds;
            myBoardId.Value = info.InstalledBoardIds{1};
            myBoardId.Enable = true;
        end
    end

%%
    function boardIdCallback(h) %#ok<INUSD>
                
        if ~isempty(myAnalogInputObj) && isvalid(myAnalogInputObj)
            delete(myAnalogInputObj);
            myAnalogInputObj = [];
            myAnalogInputInfo = [];
        end

        if all(isspace(myBoardId.Value))
            blankFields(); return;
        end
        
        try
            myAnalogInputObj = analoginput(myAdaptor.Value,myBoardId.Value);
        catch  %#ok<CTCH>
            myAnalogInputObj = [];
        end
        
        if isempty(myAnalogInputObj) || ~isvalid(myAnalogInputObj)
            blankFields(); return;
        end
        
        myAnalogInputInfo = daqhwinfo(myAnalogInputObj);
        menuItems = {};
        if ~isempty(myAnalogInputInfo.SingleEndedIDs)
            menuItems{end+1} = 'Single-Ended';
        end
        if ~isempty(myAnalogInputInfo.DifferentialIDs)
            menuItems{end+1} = 'Differential';
        end        
        if isempty(menuItems)
            blankFields(); return;
        end
            
        myChannelType.MenuItems = menuItems;
        myChannelType.Enable = true;
        myChannelType.Value = menuItems{1};
            
        mySampleRate.Value = myAnalogInputInfo.MinSampleRate;
        mySampleRate.Enable = true;
        
        function blankFields()
            myChannelType.MenuItems = {' '};
            myChannelType.Value = ' ';
            myChannelType.Enable = false;
            mySampleRate.Value = 0;
            mySampleRate.Enable = false;
        end        
    end

%%
    function channelTypeCallback(h) %#ok<INUSD>
        if isempty(myAnalogInputInfo) || all(isspace(myChannelType.Value))
            myChannels.MenuItems = {' '};
            myChannels.Value = [];
            myChannels.Enable = false;
            return;
        end        
        switch myChannelType.Value
            case 'Single-Ended'
                myChannels.MenuItems = cellstr(int2str(myAnalogInputInfo.SingleEndedIDs(:)));
            case 'Differential'
                myChannels.MenuItems = cellstr(int2str(myAnalogInputInfo.DifferentialIDs(:)));
        end
        myChannels.Value = myChannels.MenuItems{1};
        myChannels.Visible = true;
        myChannels.Enable = true;
    end

%%
    function sampleRateCallback(h) %#ok<INUSD>        
        if isempty(myAnalogInputInfo)
            return;
        end
        
        sr = mySampleRate.Value;
        
        if sr >= myAnalogInputInfo.MinSampleRate && sr <= myAnalogInputInfo.MaxSampleRate
            sr = setverify(myAnalogInputObj, 'SampleRate', sr);
        else
            sr = min(max(sr, myAnalogInputInfo.MinSampleRate), myAnalogInputInfo.MaxSampleRate);
        end
        
        mySampleRate.Value = sr;
    end

end

