% gui.monitor          
%   A class for monitoring a set of widgets.
%
%   M = gui.monitor(W1,W2,...,Wn) specifies that the widgets W1, W2 ... Wn
%     should be monitored for changes to their Value property. There are
%     two ways the caller can find out about the changes: 
%       * wait until the Value is changed (the waitForInput method), or 
%       * specify a function to be called (ValueChangedFcn property).
%    All the widgets should be in the same figure  window; if that figure
%    is deleted or closed, the monitor object M is  automatically deleted. 
%
%   M = gui.monitor(ARR) takes the cell array ARR as the set of widgets to
%     be monitored, i.e., ARR is {W1,W2...,Wn}.
%
%  --------------------------------------------
%  NOTE: The monitor method in the gui.autogui class is a
%  convenient interface to the gui.monitor class. Use this class explicitly
%  if you want to create multiple monitors, or if you need to specify
%  timeouts when using waitForInput().
%  --------------------------------------------
%
%   Sample usage:
%    g = gui.autogui;
%    w1 = gui.edittext('Your name');
%    w2 = gui.slider('Age in years', [1 100]);
%    w3 = gui.slider('Proportion', [0 1]);
%
%    m1 = gui.monitor(w1);      % monitors only w1
%    m1.ValueChangedFcn = @(h) disp(['m1 monitor: ' h.Value]); 
%
%    m2 = gui.monitor(w2,w3);   % monitors w2,w3
%    while m2.waitForInput()
%       disp(m2.LastInput.Value);
%    end
%
%    Also see:
%    <a href="matlab:help gui.monitor.LastInput">LastInput</a> (property)
%    <a href="matlab:help gui.monitor.ValueChangedFcn">ValueChangedFcn</a> (property)
%    <a href="matlab:help gui.monitor.waitForInput">waitForInput</a> (method)

%   Copyright 2009 The MathWorks, Inc.

classdef (Sealed) monitor < handle
    
    properties(GetAccess=public,SetAccess=private)
        % LastInput
        %   A handle to a widget, used in conjunction with the
        %   waitForInput() method. When waitForInput() returns
        %   successfully, the LastInput property indicates the 
        %   widget with the most-recent input activity.
        %
        %   This is a READ-ONLY property.
        % 
        %    Also see:
        %    <a href="matlab:help gui.monitor.ValueChangedFcn">ValueChangedFcn</a> (property)
        %    <a href="matlab:help gui.monitor.waitForInput">waitForInput</a> (method)
        LastInput = []
        
        % WaitTimedOut
        %   A boolean flag. 
        %    true => the most recent waitForInput() timed out
        %    false => the most recent waitForInput() did not time out 
        %   This is a READ-ONLY property.
        WaitTimedOut
        
        % MonitoredWidget
        %   A cell array of the monitored widgets.
        %   This is a READ-ONLY property.
        MonitoredWidgets
    end
    
    properties(Access=public)
        % ValueChangedFcn 
        %             
        %   ValueChangedFcn specifies an optional function handle. This 
        %   function is invoked if the Value property is changed in any of
        %   the monitored widgets. The function is invoked with one input
        %   argument (the handle to the widget). 
        %
        %   To disable ValueChangedFcn, set it to []
        ValueChangedFcn = []
        
        % Timeout
        %    The timeout value (in seconds) to be used in conjunction with 
        %    the waitForInput() method. By default, Timeout = inf.
        %
        %    The WaitTimedOut property reports whether the most recent
        %    call to waitForInput timed out or not.
        %
        %   Also see:
        %    <a href="matlab:help gui.monitor.waitForInput">waitForInput</a> (method)        
        Timeout = inf  % timeout in seconds
    end
    
    properties(Access=private)
        Listeners
        
        ParentContainer % container of all the widgets
        ParentFigure   % HG Figure handle of container
        ParentListener % listener to the ParentContainer
        ValueChangedFcnListener        
    end
    
    methods
        % conditions to test:
        % x check for repeated widgets
        % x zero arguments to constructor
        % x single cell array arg to constructor
        % x comma-sep list arg to constructor
        % multiple cells as arg to constructor
        % autogui gets deleted during a no-timeout waitForInput
        % autogui gets deleted during a timeout waitForInput        
        function obj = monitor(varargin)
            if nargin==1 && iscell(varargin{1})
                widgetList = varargin{1};
            else
                widgetList = varargin;
            end
            
            n = numel(widgetList);
            if n < 1
                throw(MException('monitor:InvalidInput', 'Parameters should be one or more handles of type gui.widget'));
            end
            
            valid = false(1,n);
            fig = zeros(1,n);
            parent = num2cell(zeros(1,n));
            
            % check validity of widgets            
            for i=1:n
                w = widgetList{i};
                valid(i) = isa(w, 'gui.widget') && isvalid(w);
                if valid(i)
                    fig(i) = ancestor(w.Parent.UiHandle, 'figure');
                    parent{i} = w.Parent; 
                end
            end            
            sameParent = all(cellfun(@(p) p == parent{1}, parent));
            if ~(all(valid) && sameParent && all(fig == fig(1)))
                throw(MException('monitor:InvalidInput', 'Parameters should be one or more handles of type gui.widget'));
            end
                
            % remove repetitions in the widgetList
            isDuplicate = false(1,n);
            for i=1:(n-1)
                for j=i+1:n
                    if widgetList{i} == widgetList{j}
                        isDuplicate(j) = true;
                    end
                end
            end
            widgetList(isDuplicate) = [];

            % now set up the listeners
            n = numel(widgetList);
            obj.Listeners = cell(1,n);            
            obj.ParentFigure = fig(1);
            obj.ParentContainer = parent{1};
            obj.ParentListener = event.listener(obj.ParentContainer, 'ObjectBeingDestroyed', @(src,e) delete(obj));
            for i=1:n
                e = event.listener(widgetList{i}, 'ValueChanged', @(src,e) valueChangedCallback(obj,src));
                e.Enabled = true;
                e.Recursive = false;
                obj.Listeners{i} = e;
            end
            obj.MonitoredWidgets = widgetList;
        end

        function delete(obj)
            for i=1:numel(obj.Listeners)
                if ~isempty(obj.Listeners{i}) && isvalid(obj.Listeners{i})
                    delete(obj.Listeners{i});
                end
            end
            delete(obj.ParentListener);
        end
        
        function allOk = waitForInput(obj)
            
            % waitForInput            gui.monitor method
            %
            %   allOk = obj.waitForInput() waits for changes to the
            %   Value property in any of the monitored widgets .
            %
            %     allOk is true => there was a change (and the
            %     corresponding widget is given by the LastInput property)
            %     or the wait timed out (and WaitTimedOut is true).
            %
            %     allOk is false => the gui was closed or deleted in the
            %     meantime. The LastInput property is undefined. 
            %
            %    Also see:
            %    <a href="matlab:help gui.monitor.WaitTimedOut">WaitTimedOut</a> (property)
            %    <a href="matlab:help gui.monitor.LastInput">LastInput</a> (property)

            
            % Potential race condition: after the obj.WaitTimedOut
            % assignment & before the uiwait kicks in, the callback happens
            % to get invoked, so we enter the waitstate with
            % obj.WaitTimedOut==false. When uiwait returns, we have no 
            % way of determining whether there was an actual timeout.
            %
            % Two possibilities: (1) there is an input during the wait, so
            % obj.WaitTimedout==false is the desired state anyway. 
            % (2) there is no input during the wait, so obj.WaitTimedout
            % should be true. However, there really was an input just
            % before uiwait kicked in and obj.LastInput will be valid, so
            % the external behavior will be consistent. 
            %
            % Conclusion: Leave the race condition alone.
        
            obj.WaitTimedOut = true;            
            
            if isinf(obj.Timeout)
                uiwait(obj.ParentFigure);
            else
                uiwait(obj.ParentFigure, obj.Timeout);
            end                                    
            
            % figure got deleted and this object got deleted as well
            allOk = isvalid(obj) && isvalid(obj.ParentContainer);            
        end

        function set.ValueChangedFcn(obj, f)
            if isa(f, 'function_handle') || isempty(f)
                obj.ValueChangedFcn = f;
            else
                throw(MException('monitor:ValueChangedFcn', 'ValueChangedFcn should be a function handle'));
            end
        end

        function set.Timeout(obj,t)
            if ~(isnumeric(t) && isscalar(t) && isreal(t) && t>0)
                throw(MException('monitor:InvalidTimeout', 'Timeout should be a positive number or Inf'));
            end
            obj.Timeout = round(t);
        end
        
        function out = isWaiting(obj)
            out = strcmp( get(obj.ParentFigure, 'waitstatus'), 'waiting' );
        end
        
    end

    methods(Hidden)
        % Note: this function is can be called asynchronously, so it has
        % the potential to modify instance variables that another method is
        % currently manipulating (and expecting to stay constant!). 
        function valueChangedCallback(obj,widget)
            obj.LastInput = widget;
            obj.WaitTimedOut = false;
            
            if ~isempty(obj.ValueChangedFcn)
                feval(obj.ValueChangedFcn, widget);
            end

            uiresume(obj.ParentFigure);            
        end
    end
    
end

