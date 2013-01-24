% gui.daqinput
%    A widget for analog data acquisition 
%
%    W = gui.daqinput() creates a widget for configuring and retrieving
%    analog data. The acquisition can be configured either programmatically
%    (by setting relevant properties) or via the GUI. The acquired data 
%    can be retrieved using the Value property.
%     
%    W = gui.daqinput(G) creates the widget and adds it to the gui
%    container G.
%
%  Note:
%    1) This widget requires the Data Acquisition Toolbox.
%    2) The data acquisition is triggered if the user clicks on the "Start"
%       button, or if the START method is called.
%    3) This widget does NOT plot the acquired data. 
%    4) If the figure window is closed (or the gui.daqinput widget is
%       explicitly deleted), any ongoing data acquisition is stopped and
%       the acquisition hardware is reset.
%
%  Sample usage:
%    g = gui.autogui;
%    daq = gui.daqinput;
%    daq.AdaptorName = 'winsound';
%    % ...
%    while g.waitForInput()
%       info = daq.Value;
%       plot(info.time, info.data);
%    end
%    delete(daq); % stops acquisition and deletes the daq.daqinput object 
%
%   Also see: 
%    <a href="matlab:help gui.daqinput.Value">gui.daqinput.Value</a>
%    <a href="matlab:help gui.daqinput.start">gui.daqinput.start</a>
%    <a href="matlab:help gui.stripchart">gui.stripchart</a>

%   Copyright 2009 The MathWorks, Inc.

classdef (Sealed) daqinput < gui.widget

    properties (Dependent)
        % Value 
        %   A structure containing the most-recently acquired data. 
        %
        %   The structure has two fields:
        %    data - The acquired samples (a matrix of size BufferSize x N),
        %          where N is the number of channels being sampled.
        %    time - The acquisition time of each sample (a vector of length
        %           BufferSize). The time is measured in seconds since the
        %           start of the acquisition.
        %           
        %   The gui.daqinput widget maintains an internal buffer (of length
        %   BufferSize), and returns this as the Value. The internal buffer
        %   is periodically updated with newly-acquired samples and the old
        %   samples are overwritten. When this update occurs, the
        %   ValueChangedFcn is invoked.  
        %
        %  Consider the following code:
        %        daq = gui.daqinput;
        %        % ...
        %        info1 = daq.Value;
        %        pause(0.2);
        %        info2 = daq.Value;        
        %  info1.data and info2.data will have the same length but not
        %  the same numbers, since the internal buffer may have been
        %  updated *one or more* times between the two calls. It is the
        %  caller's responsibility to get the Value before data is lost.
        %
        %  Also see:
        %    <a href="matlab:help gui.daqinput.BufferSize">BufferSize</a> (property)
        %    <a href="matlab:help gui.daqinput.start">start</a> (method)
        %    <a href="matlab:help gui.stripchart">gui.stripchart</a>    
        Value 
    end

    properties (Dependent, GetAccess=public, SetAccess=private)
        % Running 
        %   Indicates the state of the data acquisition. 
        %    true  => data acquisition engine is running
        %    false => data acquisition is not configured or 
        %             has not been started.
        %
        %  Also see:
        %    <a href="matlab:help gui.daqinput.start">start</a> (method)
        %    <a href="matlab:help gui.daqinput.stop">stop</a> (method)        
        Running
    end
        
    properties
        % AdaptorName
        %   A string with the name of the adaptor to use for analog data
        %   acquisition (supported adaptors are 'advantech', 'mcc',
        %   'nidaq' and 'winsound'). If the user selects the adaptor using
        %   the GUI, this property is automatically updated.
        %
        %   Sample usage:
        %    daq = gui.daqinput;
        %    daq.AdaptorName = 'winsound';
        %
        %  Also see:
        %   <a href="matlab:help daq/daqhwinfo">daqhwinfo</a>
        AdaptorName
        
        % DeviceId
        %   A string or number identifying the hardware device. If the user
        %   selects the DeviceId using the GUI, this property is
        %   automatically updated. 
        %
        %   Sample usage:
        %    daq = gui.daqinput;
        %    daq.AdaptorName = 'winsound';        
        %    daq.DeviceId = 0;
        % 
        %  Also see:
        %   <a href="matlab:help daq/daqhwinfo">daqhwinfo</a>        
        DeviceId
        
        % Channels
        %   A vector of integers, identifying the channels to be sampled
        %   from the hardware device. If the user selects the Channels 
        %   using the GUI, this property is automatically updated. 
        %
        %   Sample usage:
        %    daq = gui.daqinput;
        %    daq.AdaptorName = 'winsound';        
        %    daq.DeviceId = 0;
        %    daq.Channels = [1 2];
        Channels
        
        % SampleRate
        %   The sampling rate to be used (expressed as the number of
        %   samples per second). 
        %
        %   Sample usage:
        %    daq = gui.daqinput;
        %    daq.AdaptorName = 'winsound';        
        %    daq.SampleRate = 11025;
        SampleRate  
        
        % BufferSize
        %   The number of samples (per channel) that should be returned by
        %   the Value property. 
        %
        %   Example usage:
        %    daq = gui.daqinput;
        %    daq.BufferSize = 1024;
        % 
        %  Also see:
        %    <a href="matlab:help gui.daqinput.Value">Value</a> (property)
        BufferSize
    end
    
    properties (Access=private)
        AiObj = []
        CurrentData 
        CurrentDataTime
        
        UiTitle
        UiConfigInfo
        UiConfigButton
        UiActionButton
        
        ConfigInfoWidth
    end
        
    methods
        function obj = daqinput(varargin)               
            obj = obj@gui.widget(varargin{:});
            
            color = obj.getParentUiColor();
            
            obj.UiHandle = gui.util.uiflowcontainer('Parent',obj.ParentUiHandle, ...
                'units', 'pixels', ...
                'BackgroundColor',color, ...
                'FlowDirection', 'bottomup', ...
                'tag', 'daqinput-uihandle', ...
                'Visible', 'off', ...
                'DeleteFcn', @(h,e) delete(obj));   

            obj.UiActionButton = uicontrol('Parent', obj.UiHandle, ...
                'style','Pushbutton', ...
                'units', 'pixels', ...
                'string', 'Start', ...
                'Callback', @(h,e) startstopButtonCallback(obj));

            obj.UiConfigButton = uicontrol('Parent', obj.UiHandle, ...
                'style','Pushbutton', ...
                'units', 'pixels', ...
                'string', 'Configure', ...
                'Callback', @(h,e) configButtonCallback(obj));

            obj.UiConfigInfo = uicontrol('Parent', obj.UiHandle, ...
                'style','text', ...
                'units', 'pixels', ...
                'string', {'',''}, ...
                'HorizontalAlignment', 'Left', ...
                'FontAngle', 'italic');
                            
            obj.UiTitle = uicontrol('Parent', obj.UiHandle, ...
                'style','text', ...
                'units', 'pixels', ...
                'string', 'Analog input', ...
                'HorizontalAlignment', 'Left');           
        
            obj.AdaptorName = '';
            obj.DeviceId = '0';
            obj.Channels = [1]; %#ok<NBRAK>
            obj.SampleRate = 8000;
            obj.BufferSize = 1024;
            % obj is the most derived class             
            obj.Initialized = true;
            obj.Visible = true;                        
        end
        
        function delete(obj)       
            if obj.Running
                stop(obj);
            end            
            delete(obj.AiObj);
        end
   
    end

    
    methods
        % todo: add property (ConfigFile) to save & load config info from.
        
        function set.BufferSize(obj, sz)
            if ~(isnumeric(sz) && isscalar(sz) && isreal(sz) && sz > 0)
                throw(MException('daqinput:InvalidBufferSize', 'BufferSize should be a positive number'));
            end
            obj.BufferSize = round(sz);
        end
                        
        function set.AdaptorName(obj,name)
            if ~ischar(name) 
                throw(MException('daqinput:InvalidAdaptorName', 'Adaptor name should be a string'));
            end
            obj.AdaptorName = name;
            clearAnalogInputObject(obj);
            updateConfigString(obj);
        end
                               
        function set.DeviceId(obj,id)
            if ~(ischar(id) || (isnumeric(id) && isscalar(id)))
                throw(MException('daqinput:InvalidDeviceId', 'DeviceID should be a string or a number'));
            end
            obj.DeviceId = id;
            clearAnalogInputObject(obj);
            updateConfigString(obj);
        end
        
        function set.Channels(obj,c)
            if ~(isnumeric(c) && isvector(c))
                throw(MException('daqinput:InvalidChannels', 'Channels should be a list of channel numbers'));
            end
            obj.Channels = c;
            clearAnalogInputObject(obj);
            updateConfigString(obj);
        end
        
        function set.SampleRate(obj,rate)
            if ~(isnumeric(rate) && isscalar(rate) && isreal(rate) && rate > 0 && fix(rate)==rate)
                throw(MException('daqinput:InvalidChannels', 'SampleRate should be a positive number'));
            end            
            if ~isempty(obj.AiObj) && isvalid(obj.AiObj)
                stop(obj);
                obj.SampleRate = setverify(obj.AiObj, 'SampleRate', rate);
            else
                obj.SampleRate = rate;
            end
            updateConfigString(obj);
        end
        
        function set.Value(obj, val) %#ok<INUSD>
            throw(MException('daqinput:InvalidValue', 'Value cannot be modified'));
        end
        
        function out = get.Value(obj)
            out = struct('time', obj.CurrentDataTime, ...
                         'data', obj.CurrentData);
        end            
        
        
        function out = get.Running(obj)
            out = ~isempty(obj.AiObj) && ...
                   isvalid(obj.AiObj) && ...
                   isrunning(obj.AiObj);
        end

        function start(obj)
            % start       gui.daqinput method
            %
            %   OBJ.start() starts the data acquisition engine for
            %   gui.daqinput object OBJ (assuming that the acquisition
            %   hardware is configured correctly). If the engine is already
            %   running, this method has no effect.
            %
            %   Calling this method is equivalent to clicking on the
            %   "Start" button on the widget. 
            %
            %  Also see:
            %    <a href="matlab:help gui.daqinput.Running">Running</a> (property)

            % The UiActionButton is updated on StartFcn and StopFcn
            % callbacks (so that it reflects any unanticipated stops)
            if obj.Running, 
                return;
            end            
            if isempty(obj.AiObj) || ~isvalid(obj.AiObj)
                try
                    initializeAnalogInput(obj);
                catch ME
                    if isa(obj.AiObj, 'analoginput') && isvalid(obj.AiObj)
                        delete(obj.AiObj);
                        obj.AiObj = [];
                    end
                    errorString = {'Unable to create analog input object', ...
                                    ME.message };
                    errordlg(errorString, 'Analog input', 'modal');
                    return;
                end
            end
            start(obj.AiObj); % automatic trigger            
        end

        function stop(obj)            
            % stop       gui.daqinput method
            %
            %   OBJ.stop() stops the data acquisition engine for
            %   gui.daqinput object OBJ. If the engine is already stopped,
            %   this method has no effect.
            %
            %   Calling this method is equivalent to clicking on the
            %   "Stop" button on the widget.
            %
            %  Also see:
            %    <a href="matlab:help gui.daqinput.Running">Running</a> (property)
            
            if ~obj.Running, 
                return;
            end
            stop(obj.AiObj);
        end
        
    end
    
    methods(Access=private)
        % errors should be caught by caller
        function initializeAnalogInput(obj)
            assert(isempty(obj.AiObj) || ~isvalid(obj.AiObj));
            if isempty(obj.AdaptorName) 
                throw(MException('daqinput:InvalidConfiguration', ...
                    'Adaptor name is not configured'));                
            end
            
            % Use a numeric device Id if possible, as it yields a more
            % useful message in case of error
            devIdNum = str2double(obj.DeviceId);
            if ~isnan(devIdNum)
                obj.AiObj = analoginput(obj.AdaptorName, devIdNum);
            else
                obj.AiObj = analoginput(obj.AdaptorName, obj.DeviceId);
            end
            set(obj.AiObj, 'tag', 'gui.daqinput');
            addchannel(obj.AiObj, obj.Channels);
            obj.SampleRate = setverify(obj.AiObj, 'SampleRate', obj.SampleRate);
            
            set(obj.AiObj, 'SamplesPerTrigger', inf);
            set(obj.AiObj, 'SamplesAcquiredFcnCount', obj.BufferSize, ...
                           'SamplesAcquiredFcn', @(h,e) localDaqGetData(obj), ...
                           'StartFcn', @(h,e) updateAiStatus(obj,true), ...
                           'StopFcn', @(h,e) updateAiStatus(obj,false), ...
                           'RuntimeErrorFcn', @(h,e) localDaqErrorFcn(obj,e));

            obj.CurrentData = zeros(obj.BufferSize,1);
            obj.CurrentDataTime = zeros(obj.BufferSize,1);
        end
       
    end

    methods(Hidden)
        
        function updateAiStatus(obj, acqStarting)
            if acqStarting
                set(obj.UiActionButton, 'String', 'Stop');
            else
                set(obj.UiActionButton, 'String', 'Start');
            end                
        end
        
        % invoked whenever there is a runtime error in the data acquisition
        % (the default handler for this is daqcallback.m).
        function localDaqErrorFcn(obj, event) %#ok<INUSL>
            msg = sprintf('%s event occurred during the data acquisition', event.Type);
            errordlg(msg, 'Analog input', 'modal');
        end
        
        function localDaqGetData(obj)
            n = get(obj.AiObj, 'SamplesAvailable');
            if n < obj.BufferSize, return; end
            % obj.CurrentData will have multiple columns if # of channels > 1
            [obj.CurrentData, obj.CurrentDataTime] = getdata(obj.AiObj, obj.BufferSize);
            notify(obj, 'ValueChanged');
        end
        
        
        function startstopButtonCallback(obj)
            if ~obj.Running
                start(obj);                
            else
                stop(obj);
            end
        end
        
        function configButtonCallback(obj)
            currentConfig = struct('adaptor', obj.AdaptorName, ...
                                   'boardId', obj.DeviceId, ...
                                   'channels', obj.Channels, ...
                                   'sampleRate', obj.SampleRate);
            newConfig = guiGetDaqInputParams(currentConfig);
            if ~isempty(newConfig)
               obj.AdaptorName = newConfig.adaptor;
               obj.DeviceId = newConfig.boardId;
               obj.Channels = newConfig.channels;
               obj.SampleRate = newConfig.sampleRate;
            end
        end        
    end
    
    methods(Access=protected)
        function initNotify(obj)
            [width,totalHeight] = updateSize(obj);
            obj.Position = struct('width', width, 'height', totalHeight);       
            
            if ~license('test','Data_Acq_Toolbox')
                warning('daqinput:MissingDataAcqToolbox', ...
                    'This demo requires the Data Acquisition Toolbox');
            end
            
        end
        
        % called after position is changed
        % pos is [x y w h] the new position.
        % nan's indicate default (unmodified) values
        function postPositionChange(obj, pos)   %#ok<INUSD>
            if ~isnan(pos(3))
                % the -5 is a fudge factor to clean up edges
                updateSize(obj, pos(3)-5);
                % there is no simple way to get from pixel size of the
                % uicontrol to number of characters (the 'characters' units
                % does a fixed scaling and ignores fontsize; the 'extent' 
                % property says how big the uicontrol must be to fit the
                % text but not how big the text can be to fit the
                % uicontrol). So use a default scaling.
                pixelsPerCharWidth = 7;
                obj.ConfigInfoWidth = floor(pos(3)/pixelsPerCharWidth);
                updateConfigString(obj);
            end
        end        
    end
    
    methods(Access=private)
        function clearAnalogInputObject(obj)
            if ~isempty(obj.AiObj)
                if obj.Running
                    stop(obj);
                end
                delete(obj.AiObj);
                obj.AiObj = [];
            end
        end
        
        function updateConfigString(obj)
            switch numel(obj.Channels)
                case 0, channelStr = 'No channels';
                case 1, channelStr = ['channel ' num2str(obj.Channels)];
                otherwise                    
                    channelLst = sprintf('%d,',obj.Channels);
                    channelStr = ['channels ' channelLst(1:end-1)];
            end
            
            if isempty(obj.AdaptorName)
                row1 = 'No adaptor';
            else
                if isnumeric(obj.DeviceId)
                    deviceIdStr = num2str(obj.DeviceId);
                else
                    deviceIdStr = obj.DeviceId;
                end                
                row1 = sprintf('Adaptor %s (%s)', obj.AdaptorName, deviceIdStr); 
            end
            
            row2 = sprintf('%s at %d Hz', channelStr, obj.SampleRate);
            set(obj.UiConfigInfo, 'string', ...
                {trimString(row1,obj.ConfigInfoWidth), ...
                 trimString(row2,obj.ConfigInfoWidth)});
        end
        
        function [width,totalHeight] = updateSize(obj, newwidth)
            titleExtent = get(obj.UiTitle,'Extent'); % x y w h            
            configInfoExtent = get(obj.UiConfigInfo, 'Extent');             
            configExtent = get(obj.UiConfigButton,'Extent'); % x y w h

            if exist('newwidth','var') && newwidth > 0
                width = newwidth;
            else
                width = max([titleExtent(3) configInfoExtent(3) configExtent(3)]) + 10;
            end
            
            totalHeight = titleExtent(4) + configInfoExtent(4) + 2*configExtent(4) + 20;
            
            set(obj.UiTitle, 'HeightLimits', titleExtent([4 4]), ...
                             'WidthLimits',  width([1 1]));

            set(obj.UiConfigInfo, 'HeightLimits', configInfoExtent([4 4]), ...
                                  'WidthLimits',  width([1 1]));
                                         
            set(obj.UiConfigButton, 'HeightLimits', configExtent([4 4]), ...
                                    'WidthLimits',  width([1 1]));
                                
            set(obj.UiActionButton, 'HeightLimits', configExtent([4 4]), ...
                                    'WidthLimits',  width([1 1]));
        end
        
    end
    
end

function out = trimString(s, maxlen)
if numel(s) > maxlen 
    if maxlen < 3
        out = s(1:maxlen);
    else
        out = [s(1:maxlen-2) '..'];
    end
else
    out = s;
end
end

