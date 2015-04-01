classdef MultiAxis < handle

    properties(SetAccess=protected)
        figh % figure attached to
        
        axhDraw % overly axis for drawing
        axhOverlay % for plot labels, etc.
        
        current % currently selected Container instance for use by plotting tools
        
        % status flags
        drawActive = false; % overlays being drawn
        midUpdate = false; % in the middle of a call to update
        
        % used for associating handles with tags so that tagged objects can be
        % looked up when loading from disk
        tagDict
        
        installedCallbacks = false;
        requiresReconfigure = false;
    end
    
    properties
        root % root level container
        
        labelFontColor
        labelFontSize
        labelFontWeight

        titleFontSize
        titleFontColor
    end
    
    methods % Constructor
        function ma = MultiAxis(figh)
            if nargin < 1 || isempty(figh)
                figh = gcf;
            end
            
            ma = MultiAxis.createOrRecoverInstance(ma, figh);
        end
    end

    methods(Static) % static utility methods and callbacks
        function figureCallback(figh, varargin)
            if MultiAxis.isMultipleCall(), return, end;
            MultiAxis.updateFigure(figh);
            
            % TODO add AutoAxis updateFigure callback
        end
        
        function updateFigure(figh)
            % call auto axis update for every managed axis in a figure
            if nargin < 1
                figh = gcf;
            end
            
            ma = MultiAxis.recover(figh);
            ma.update();
        end
        
        function updateIfInstalled(figh)
            if nargin < 1
                figh = gcf;
            end
            
            ma = MultiAxis.recover(figh);
            if ~isempty(ma)
                ma.update();
            end
        end

        function flag = isMultipleCall()
            % determine whether callback is being called within itself
            flag = false; 
            % Get the stack
            s = dbstack();
            if numel(s) <= 2
                % Stack too short for a multiple call
                return
            end

            % How many calls to the calling function are in the stack?
            names = {s(:).name};
            TF = strcmp(s(2).name,names);
            count = sum(TF);
            if count>1
                % More than 1
                flag = true; 
            end
        end
        
        function hvec = allocateHandleVector(num)
            if verLessThan('matlab','8.4.0')
                hvec = nan(num, 1);
            else
                hvec = gobjects(num, 1);
            end
        end
        
        function hvec = allocateHandleMatrix(nRow, nCol)
            if verLessThan('matlab','8.4.0')
                hvec = nan(nRow, nCol);
            else
                hvec = gobjects(nRow, nCol);
            end
        end
        
        function hn = getNullHandle()
            if verLessThan('matlab','8.4.0')
                hn = NaN;
            else
                hn = matlab.graphics.GraphicsPlaceholder();
            end
        end
        
        function [hvec, mask] = filterValidHandles(hvec)
            % remove invalid handles and GraphicsPlaceholders, flattens the
            % array
            if verLessThan('matlab','8.4.0')
                mask = isvalid(hvec);
                hvec = makecol(hvec(mask(:)));
            else
                mask = arrayfun(@(h) isvalid(h) && ~isa(h, 'matlab.graphics.GraphicsPlaceholder'), hvec);
                hvec = makecol(hvec(mask(:)));
            end
        end  
        
        function mask = isValidHandle(hvec)
            % test for invalid handles and GraphicsPlaceholders, flattens the
            % array
            if verLessThan('matlab','8.4.0')
                mask = isvalid(hvec);
            else
                mask = arrayfun(@(h) isvalid(h) && ~isa(h, 'matlab.graphics.GraphicsPlaceholder'), hvec);
            end
        end  
        
        function fig = getParentFigure(axh)
            % if the object is a figure or figure descendent, return the
            % figure. Otherwise return [].
            fig = axh;
            while ~isempty(fig) && ~strcmp('figure', get(fig,'type'))
              fig = get(fig,'parent');
            end
        end
        
        function ma = recover(figh)
            % recover the MultiAxis instance associated with figure figh
            if nargin < 1, figh = gcf; end;
            ma = getappdata(figh, 'MultiAxisInstance');
        end
        
        function ma = createOrRecoverInstance(ma, figh)
            % if an instance is installed for this figure
            % then return the existing instance, otherwise create a new one
            % and install it
            
            maTest = MultiAxis.recover(figh);
            if isempty(maTest) || isempty(maTest.axhDraw) || ~isvalid(maTest.axhDraw)
                % not installed, create new
                ma.initializeNewInstance(figh);
                ma.installInstance();
            else
                % return the existing instance
                ma = maTest;
            end
        end
          
        function tag = generateFigureUniqueTag(figh, prefix)
            if nargin < 2
                prefix = 'multiAxis';
            end
            while true
                validChars = ['a':'z', 'A':'Z', '0':'9'];
                tag = sprintf('%s_%s', prefix, randsample(validChars, 20));
                % validate the tag is unique if possible
                if nargin >= 1
                    obj = findall(figh, 'Tag', tag);
                    if isempty(obj)
                        return;
                    end
                else
                    return;
                end
            end
        end
    end
    
    methods
        function initializeNewInstance(ma, figh)
            ma.figh = figh;
            
            clf(ma.figh);
            
            % initialize handle tagging (for load/copy
            % auto-reconfiguration)
            ma.tagDict = containers.Map('KeyType', 'char', 'ValueType', 'any');
            ma.figh = figh;
            
            % create overlay axes
            oldCA = get(figh, 'CurrentAxes');
            
            ma.axhDraw = axes('Position', [0 0 1 1], 'Parent', figh);
            set(ma.axhDraw, 'Color', 'none', 'HitTest', 'off');
            axis(ma.axhDraw, 'off');
            uistack(ma.axhDraw, 'bottom');

            ma.axhOverlay = axes('Position', [0 0 1 1], 'Parent', figh);
            set(ma.axhOverlay, 'Color', 'none', 'HitTest', 'off');
            axis(ma.axhOverlay, 'off');
            uistack(ma.axhOverlay, 'bottom');
            
            set(figh, 'CurrentAxes', oldCA);
                
            % tag overlay axis
            set(ma.axhDraw, 'Tag', 'multiAxisOverlay');
            hold(ma.axhDraw, 'on');
            
            % create root container to fill figure
            ma.root = MultiAxis.Container(ma, [0 0 1 1]);
            ma.current = ma.root;
            
            % initialize font details from defaults
            sz = get(ma.figh, 'DefaultAxesFontSize');
            tc = get(ma.figh, 'DefaultTextColor');
            ma.labelFontColor = tc;
            ma.labelFontSize = ceil(sz * 1.3);
            ma.labelFontWeight = 'bold';
            ma.titleFontSize = sz;
            ma.titleFontColor = tc;
        end
             
        function installInstance(ma)
            setappdata(ma.figh, 'MultiAxisInstance', ma); 
            ma.installCallbacks();
        end

        function installCallbacks(ma)
            figh = ma.figh; %#ok<*PROP>
            set(ma.figh, 'ResizeFcn', @(varargin) MultiAxis.figureCallback(figh)) %#ok<*MCNPN>
            ma.installedCallbacks = true;
        end
        
        function update(ma)
            if ma.midUpdate % prevent re-entrancy
                return;
            end
            
            if ~ishandle(ma.figh)
                return;
            end
            
            ma.midUpdate = true;
            
            % complete the reconfiguration process after loading
            if ma.requiresReconfigure
                ma.reconfigurePostLoad();
            end
              
            oldCA = get(ma.figh, 'CurrentAxes');
            if isempty(ma.axhDraw) || ~isvalid(ma.axhDraw)
                ma.axhDraw = axes('Position', [0 0 1 1], 'Parent', ma.figh);
            end
            set(ma.axhDraw, 'XLim', [0 1], 'YLim', [0 1]); % give limits same as normalized coordinates
            axis(ma.axhDraw, 'off');
            set(ma.axhDraw, 'Color', 'none', 'HitTest', 'off', 'PickableParts', 'none');
            set(ma.axhDraw, 'LooseInset', [0 0 0 0]);
            uistack(ma.axhDraw, 'bottom');
            
            if isempty(ma.axhOverlay) || ~isvalid(ma.axhOverlay)
                ma.axhOverlay = axes('Position', [0 0 1 1], 'Parent', ma.figh);
            end
            set(ma.axhOverlay, 'XLim', [0 1], 'YLim', [0 1]); % give limits same as normalized coordinates
            axis(ma.axhOverlay, 'off');
            set(ma.axhOverlay, 'Color', 'none', 'HitTest', 'off', 'PickableParts', 'none');
            set(ma.axhOverlay, 'LooseInset', [0 0 0 0]);
            uistack(ma.axhDraw, 'bottom');
            
           set(ma.figh, 'CurrentAxes', oldCA);
            
            u = get(ma.figh, 'Units');
            set(ma.figh, 'Units', 'centimeters');
            figPos = get(ma.figh, 'Position');
            set(ma.figh, 'Units', u);
            
            ma.root.update([0 0 1 1], figPos(3), figPos(4));
            
            if ma.drawActive
                ma.draw();
            end
            
            set(ma.axhDraw, 'HitTest', 'off', 'PickableParts', 'none');
            
            ma.midUpdate = false;
        end
        
        function uninstall(ma)
            set(ma.figh, 'ResizeFcn', []);
            
            % restore auto axis callbacks if installed since we would have
            % overriden them
            axCell = MultiAxis.recoverForFigure(ma.figh);
            if ~isempty(axCell)
                axCell{1}.installCallbacks();
            end
            
            % delete overlay axis
            if ~isempty(ma.axhDraw) && isvalid(ma.axhDraw)
                delete(ma.axhDraw);
            end
        end
        
        function reconfigurePostLoad(ma)
            % when loading from .fig files, all of the handles for the
            % graphics objects will have changed. go through each
            % referenced handle, look up its tag, and then replace the
            % reference with the new handle number.
            
            % loop through all of the tags we've stored, and build a map
            % from old handle to new handle
            
            % first find the overlay axis and update that handle
            ma.axhDraw = findall(ma.figh, 'Tag', ma.tagOverlayAxis);
            if isempty(ax.axhDraw)
                ma.uninstall();
                error('Could not locate overlay axis. Uninstalling');
            end
            
            % update tagDict with new handles
            tags = ma.tagDict.keys;
            for iH = 1:numel(oldH)
                hNew = findall(ma.figh, 'Tag', tags{iH});
                if isempty(hNew)
                    warning('Could not recover tagged handle');
                    hNew = MultiAxis.getNullHandle();
                end
                
                ma.tagDict(tags{iH}) = hNew(1);
            end
        end
        
        function tags = tagHandle(ma, hvec)
            % for each handle in vector hvec, set 'Tag'
            % on that handle to be something unique across the figure.
            % then store the Tag into tagDict --> handle. Don't overwrite
            % the tag if it already has one, to play nice with AutoAxis
            % and other tools.
            tags = cell(numel(hvec), 1);
            for iH = 1:numel(hvec)
                tags{iH} = get(hvec(iH), 'Tag');
                if isempty(tags{iH})
                    tags{iH} = MultiAxis.generateFigureUniqueTag(ma.figh);
                    set(hvec(iH), 'Tag', tags{iH});
                end
                ma.tagDict(hvec(iH)) = tags{iH};
            end
        end
    end
    
    methods % Pass thru to root container
        function draw(ma)
            ma.update();
            cla(ma.axhDraw);
            ma.root.draw(parula(10), 1);
            ma.drawActive = true;
        end
        
        function clearDraw(ma)
            cla(ma.axhDraw);
            ma.drawActive = false;
        end
        
        function reset(ma)
            % don't delete axhDraw here since it is created in the
            % constructor
            ma.root.reset();
        end
        
        function clear(ma)
            ma.root.clear();
        end
        
        function grid(ma, varargin)
            ma.root.grid(varargin{:});
        end
        
        function axh = axis(ma, varargin)
            axh = ma.root.axis(varargin{:});
        end
        
        function aa = autoAxis(ma, varargin)
            aa = ma.root.autoAxis(varargin{:});
        end
        
        function child = cell(ma, varargin)
            child = ma.root.cell(varargin{:});
        end
    end
    
end
