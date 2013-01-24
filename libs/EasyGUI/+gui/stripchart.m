% gui.stripchart
%    A class for plotting data in a continuous scroll.  
%
%    C = gui.stripchart() creates an axes in the current figure for
%    plotting a stripchart. To add new data to the plot, use the method
%    UPDATE. If the figure or axes is deleted, the stripchart object C is
%    automatically deleted.
% 
%    C = gui.stripchart(AX) uses the axes AX for the stripchart. This axes
%    handle can be retrieved later with the property UiAxes.
%
%    C = gui.stripchart(AX, NUMPOINTS) uses the axes AX for the stripchart,
%    and sets the NumPoints property (the total width of the stripchart) to
%    NUMPOINTS. 
% 
%   Sample usage:
%     c = gui.stripchart;
%     for i=1:300
%       data = rand(1) * sin(0:0.1:2*pi);
%       c.update(data);
%       pause(0.01);
%     end
%
%   Also see: 
%    <a href="matlab:help gui.stripchart.update">update</a> (method)
%    <a href="matlab:help gui.daqinput">gui.daqinput</a>

%   Copyright 2009 The MathWorks, Inc.

classdef stripchart < handle
        
    properties(GetAccess=public, SetAccess=private)
        % UiAxes
        %   The handle to the stripchart axes. This property can be 
        %   used to adjust the axes appearance (deleting the axes will
        %   automatically delete the stripchart object as well).
        %
        %   Sample usage:
        %    c = gui.stripchart;
        %    c.update(sin(0:0.01:20));
        %    set(c.UiAxes, 'Color', 'k');
        %    grid(c.UiAxes, 'on');
        UiAxes
        
        % UiLine
        %   The handle to the stripchart plot. This property can be 
        %   used to adjust the line appearance (deleting the line will
        %   automatically delete the stripchart object as well).
        %
        %   Sample usage:
        %    c = gui.stripchart;
        %    c.update(sin(0:0.01:20));
        %    set(c.UiAxes, 'Color', 'k');
        %    set(c.UiLine, 'Color', 'g', 'LineWidth', 1);
        %    
        UiLine
        
        % NumPoints
        %   The total number of points in the stripchart. When N new points
        %   are added to the stripchart (using the UPDATE method), the N
        %   oldest points are deleted. By default, NumPoints is 4096. 
        %   
        %   The NumPoints property is automatically increased in certain
        %   conditions (see the <a href="matlab:help gui.stripchart.update">update</a> method).
        NumPoints
    end
    
    properties(GetAccess=public,SetAccess=private)
        % X
        %   The current x-axis values for the entire stripchart (a
        %   vector of length NumPoints).
        X
        
        % Y
        %   The current y-axis values for the entire stripchart (a
        %   vector of length NumPoints).
        Y
    end
    
    methods
        function obj = stripchart(hAxes, numPoints)
            if ~exist('hAxes', 'var')
                hAxes = gca;
            end
            if ~exist('numPoints', 'var')
                numPoints = 4096;
            end
            if ~(ishandle(hAxes) && strcmp(get(hAxes,'type'),'axes'))
               throw(MException('stripchart:InvalidAxes', 'Invalid axes handle'));
            end
            obj.UiAxes = hAxes;            
            obj.NumPoints = numPoints;
            % don't initialize X (we don't know whether we'll be using
            % samples or time ).
            obj.X = [];
            obj.Y = [];
            obj.UiLine = plot(nan, nan, 'parent', hAxes);
            set(obj.UiLine, 'DeleteFcn', @(h,e) delete(obj));
        end
            
        function update(obj, x, y)
            % update       gui.stripchart method
            %
            %   OBJ.update(x,y) updates the stripchart OBJ with the data
            %   points specified by x and y (vectors of length N). x is
            %   assumed to be monotonically increasing. 
            %
            %   OBJ.update(y)   updates the y-axis of the stripchart OBJ
            %   with the data in y (a vector of length N). The x-axis is
            %   unchanged. 
            %   
            %  Note: 
            %   1) If N <= NumPoints, the N oldest points in the stripchart
            %      are deleted. If N > NumPoints, then NumPoints is
            %      increased to match the new data. 
            %   2) Callers should consistently use either update(x,y) or
            %      update(y). If calls are intermingled, the x-axis of the
            %      stripchart may change unexpectedly.
            %   3) When using update(x,y), successively calls should have
            %      monotonically increasing values of x. Otherwise, the
            %      x-axis of the stripchart may change unexpectedly.
            %
            %  Sample usage:
            %    t = 0:0.01:40;
            %    c1 = gui.stripchart(subplot(2,1,1), 500);            
            %    for i=1:200:length(t)-1
            %       c1.update( sin(t(i:i+200)) );
            %       pause(0.1);
            %    end
            %
            %    c2 = gui.stripchart(subplot(2,1,2), 500);
            %    for i=1:200:length(t)-1
            %       c2.update( t(i:i+200), sin(t(i:i+200)) );
            %       pause(0.1);
            %    end
            %
            %   Also see:
            %    <a href="matlab:help gui.stripchart.UiLine">UiLine</a> (property)
            %    <a href="matlab:help gui.stripchart.UiAxes">UiAxes</a> (property)                        
                        
            if ~exist('y', 'var')
                % set only the y-axis
                if isempty(obj.X)
                    obj.X = (1:obj.NumPoints).';
                    obj.Y = zeros(obj.NumPoints,1);                    
                    set(obj.UiLine, 'xdata', obj.X, 'ydata', obj.Y);
                    set(obj.UiAxes, 'xlim', [1 obj.NumPoints]);
                end
                
                y = x; 
                ny=numel(y);
                obj.Y = [obj.Y(ny+1:obj.NumPoints) ; y(:)];
                if ny > obj.NumPoints
                    obj.NumPoints = ny;
                    obj.X = (1:obj.NumPoints).';
                    set(obj.UiLine, 'xdata', obj.X, 'ydata', obj.Y);
                    set(obj.UiAxes, 'xlim', [1 obj.NumPoints]);
                else
                    set(obj.UiLine, 'ydata', obj.Y);
                end                
            else
                
                % set both X and Y
                nx=numel(x); ny=numel(y);
                if nx ~= ny
                    throw(MException('stripchart:InvalidXYData', 'x and y vectors must have same length'));
                end
                
                % reset X and Y if just starting, or if time hasn't
                % increased monotonically
                if isempty(obj.X) || (x(1) < obj.X(end))
                    obj.X = zeros(obj.NumPoints,1);
                    obj.Y = zeros(obj.NumPoints,1);                    
                end
                                
                obj.X = [obj.X(nx+1:obj.NumPoints) ; x(:)];
                obj.Y = [obj.Y(ny+1:obj.NumPoints) ; y(:)];
                if ny > obj.NumPoints
                    obj.NumPoints = ny;
                end
                set(obj.UiLine, 'xdata', obj.X, 'ydata', obj.Y);                
                xlim = obj.X([1 end]);
                if ~any(isnan(xlim)) && xlim(2) >= xlim(1)
                    set(obj.UiAxes, 'xlim', xlim);
                end
            end
            
        end
                
    end % of methods
        
end
