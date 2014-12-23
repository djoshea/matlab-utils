classdef MultiAxis < handle


    methods
        function ma = MultiAxis(figh)
            if nargin < 1 || isempty(figh)
                figh = gcf;
            end
            
            ma = MultiAxis.createOrRecoverInstance(ma, figh);
        end
    end

    methods(Static)
        function figureCallback(figh, varargin)
            if MultiAxis.isMultipleCall(), return, end;
            MultiAxis.updateFigure(figh);
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
        
        function hn = getNullHandle()
            if verLessThan('matlab','8.4.0')
                hn = NaN;
            else
                hn = matlab.graphics.GraphicsPlaceholder();
            end
        end
        
        function updateFigure(figh)
            % call auto axis update for every managed axis in a figure
            if nargin < 1
                figh = gcf;
            end
            
            axCell = AutoAxis.recoverForFigure(figh);
            for i = 1:numel(axCell)
                axCell{i}.update();
            end
        end
        
        function updateIfInstalled(axh)
            if nargin < 1
                axh = gca;
            end
            
            au = AutoAxis.recoverForAxis(axh);
            if ~isempty(au)
                au.update();
                au.installCallbacks();
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
        
        function p = getPanelForFigure(figh)
            % return a handle to the panel object associated with figure
            % figh or [] if not associated with a panel
            p = panel.recover(figh);
%             if isempty(p)
%                 p = panel.recover(figh);
%             end
        end
        
        function axCell = recoverForFigure(figh)
            % recover the AutoAxis instances associated with all axes in
            % figure handle figh
            if nargin < 1, figh = gcf; end;
            hAxes = findobj(figh, 'Type', 'axes');
            axCell = cell(numel(hAxes), 1);
            for i = 1:numel(hAxes)
                axCell{i} = AutoAxis.recoverForAxis(hAxes(i));
            end
            
            axCell = axCell(~cellfun(@isempty, axCell));
        end
        
        function ax = recoverForAxis(axh)
            % recover the AutoAxis instance associated with the axis handle
            % axh
            if nargin < 1, axh = gca; end
            ud = get(axh, 'UserData');
            if isempty(ud) || ~isstruct(ud) || ~isfield(ud, 'autoAxis')
                ax = [];
            else
                ax = ud.autoAxis;
            end
        end
        
        function ax = createOrRecoverInstance(ax, axh)
            % if an instance is stored in this axis' UserData.autoAxis
            % then return the existing instance, otherwise create a new one
            % and install it
            
            axTest = AutoAxis.recoverForAxis(axh);
            if isempty(axTest)
                % not installed, create new
                ax.initializeNewInstance(axh);
                ax.installInstanceForAxis(axh);
            else
                % return the existing instance
                ax = axTest;
            end
        end
    end
    
    methods
        function initializeNewInstance(ax, axh)
            ax.axh = axh;
            
            % initialize handle tagging (for load/copy
            % auto-reconfiguration)
            ax.handleTagObjects = AutoAxis.allocateHandleVector(0);
            ax.handleTagStrings = {};
            ax.nextTagId = 1;
            
            % determine whether we're drawing into an overlay axis
            % or directly into this axis
            figh = AutoAxis.getParentFigure(ax.axh);
            if strcmp(get(figh, 'Renderer'), 'OpenGL')
                % create the overlay axis
                ax.usingOverlay = true;
                
                % create the overlay axis on top, without changing current
                % axes
                oldCA = gca; % cache gca
                ax.axhDraw = axes('Position', [0 0 1 1], 'Parent', figh);
                axis(ax.axhDraw, axis(ax.axh));
                axes(oldCA); % restore old gca
                
                % tag overlay axis with a random figure-unique string so
                % that we can recover it later (don't use tagHandle here, 
                % which is for the contents of axhDraw which don't need to
                % be figure unique)
                randomTag = sprintf('autoAxisOverlay_%d', randi(intmax));
                ax.tagOverlayAxis = randomTag;
                set(ax.axhDraw, 'Tag', randomTag);
                hold(ax.axhDraw, 'on');
                
                ax.updateOverlayAxisPositioning();
            else
                ax.usingOverlay = false;
                ax.axhDraw = ax.axh;
            end
            
            %ax.hMap = containers.Map('KeyType', 'char', 'ValueType', 'any'); % allow handle arrays too
            ax.anchorInfo = AutoAxis.AnchorInfo.empty(0,1);
            ax.anchorInfoDeref = [];
            ax.collections = struct();
            
            sz = get(ax.axh, 'FontSize');
            tc = get(ax.axh, 'DefaultTextColor');
            lc = get(ax.axh, 'DefaultLineColor');
            ax.tickColor = lc;
            ax.tickLineWidth = 1;
            ax.tickFontSize = sz;
            ax.tickFontColor = tc;
            ax.labelFontColor = tc;
            ax.labelFontSize = sz;
            ax.titleFontSize = sz;
            ax.titleFontColor = tc;
            ax.scaleBarColor = lc;
            ax.scaleBarFontSize = sz;
            ax.scaleBarFontColor = tc;

            ax.mapLocationHandles = AutoAxis.allocateHandleVector(0);
            ax.mapLocationCurrent = {};
        end
             
        function installInstanceForAxis(ax, axh)
            ud = get(axh, 'UserData');
             if ~isstruct(ud)
                ud = struct('autoAxis', ax);
            else
                ud.autoAxis = ax;
            end
            set(axh, 'UserData', ud);
        end
        
        function installCallbacks(ax)
%             lh(1) = addlistener(ax.axh, {'XLim', 'YLim'}, ...
%                 'PostSet', @ax.updateLimsCallback);
            figh = AutoAxis.getParentFigure(ax.axh);
            set(zoom(ax.axh),'ActionPostCallback',@ax.axisCallback);
            set(pan(figh),'ActionPostCallback',@ax.axisCallback);
            set(figh, 'ResizeFcn', @(varargin) AutoAxis.figureCallback(figh))
            addlistener(ax.axh, 'YDir', 'PostSet', @(varargin) ax.axisCallback());
            addlistener(ax.axh, 'XDir', 'PostSet', @(varargin) ax.axisCallback());
            
            p = AutoAxis.getPanelForFigure(figh);
            if ~isempty(p)
                p.setCallback(@(varargin) AutoAxis.figureCallback(figh));
            end
            %set(figh, 'ResizeFcn', @(varargin) disp('resize'));
            %addlistener(ax.axh, 'Position', 'PostSet', @(varargin) disp('axis size'));
            %addlistener(figh, 'Position', 'PostSet', @ax.figureCallback);
        end
        
%          function uninstall(~)
% %             lh(1) = addlistener(ax.axh, {'XLim', 'YLim'}, ...
% %                 'PostSet', @ax.updateLimsCallback);
%             return;
%             figh = ax.getParentFigure();
%             set(pan(figh),'ActionPostCallback', []);
%             set(figh, 'ResizeFcn', []);
%             %addlistener(ax.axh, 'Position', 'PostSet', @ax.updateFigSizeCallback);
%         end
        
        function tf = checkLimsChanged(ax)
            tf = ~isequal(get(ax.axh, 'XLim'), ax.lastXLim) || ...
                ~isequal(get(ax.axh, 'YLim'), ax.lastYLim);
        end
        
        function updateLimsCallback(ax, varargin)
            if ax.isMultipleCall(), return, end;
                
            if ax.checkLimsChanged()
                ax.update();
            end
        end
        
        function axisCallback(ax, varargin)
            if ax.isMultipleCall(), return, end;
%             % callback called on specific axis
%             if ThreeVector.isMultipleCall(), return, end;
             if numel(varargin) >= 2 && isstruct(varargin{2}) && isfield(varargin{2}, 'Axes')
                 axh = varargin{2}.Axes;
                 if ax.axh ~= axh
                     % axis handle mismatch, happens each time we save/load
                     % a figure. need to remap handle pointers
                     ax.axh = axh;
                     ax.reconfigurePostLoad();
                 end
             end
             if ~isempty(ax.axh)
                 ax.update();
             end
        end
        
        function reconfigurePostLoad(ax)
            % when loading from .fig files, all of the handles for the
            % graphics objects will have changed. go through each
            % referenced handle, look up its tag, and then replace the
            % reference with the new handle number.
            
            % loop through all of the tags we've stored, and build a map
            % from old handle to new handle
            
            % first find the overlay axis
            figh = AutoAxis.getParentFigure(ax.axh);
            ax.axhDraw = findobj(figh, 'Tag', ax.tagOverlayAxis);
            if isempty(ax.axhDraw)
                error('Could not locate overlay axis. Uninstalling');
                %ax.uninstall();
            end
            
            % build map old handle -> new handle
            oldH = ax.handleTagObjects;
            newH = oldH;
            tags = ax.handleTagStrings;
            for iH = 1:numel(oldH)
                hNew = findobj(ax.axhDraw, 'Tag', tags{iH});
                if isempty(hNew)
                    warning('Could not recover tagged handle');
                    hNew = AutoAxis.getNullHandle();
                end
                
                newH(iH) = hNew(1);
            end
            
            % go through anchors and replace old handles with new handles
            for iA = 1:numel(ax.anchorInfo)
                ax.anchorInfo(iA).ha = updateHVec(ax.anchorInfo(iA).ha, oldH, newH);
                ax.anchorInfo(iA).h  = updateHVec(ax.anchorInfo(iA).h, oldH, newH);
            end
            
            % go through collections and relace old handles with new
            % handles
            cNames = fieldnames(ax.collections);
            for iC = 1:numel(cNames)
                ax.collections.(cNames{iC}) = updateHVec(ax.collections.(cNames{iC}));
            end
            
            function new = updateHVec(old, oldH, newH)
                new = old;
                for iOld = 1:numel(old)
                    [tf, idx] = ismember(old, oldH);
                    if tf
                        new(iOld) = newH{idx};
                    else
                        new(iOld) = AutoAxis.getNullHandle();
                    end
                end
            end     
        end
        
        function tags = tagHandle(ax, hvec)
            % for each handle in vector hvec, set 'Tag'
            % on that handle to be something unique, and add this handle and
            % its tag to the .handleTag lookup table. 
            % This is used by recoverTaggedHandles
            % to repopulate stored handles upon figure loading or copying
            
            tags = cell(numel(hvec), 1);
            for iH = 1:numel(hvec)
                tags{iH} = ax.lookupHandleTag(hvec(iH));
                if isempty(tags{iH})
                    % doesn't already exist in map
                    tags{iH} = sprintf('autoAxis_%d', ax.nextTagId);
                    ax.nextTagId = ax.nextTagId + 1;
                    ax.handleTagObjects(end+1) = hvec(iH);
                    ax.handleTagStrings{end+1} = tags{iH};
                end
                
                set(hvec(iH), 'Tag', tags{iH});
            end
        end
        
        function tag = lookupHandleTag(ax, h)
            [tf, idx] = ismember(h, ax.handleTagObjects);
            if tf
                tag = ax.handleTagStrings{idx(1)};
            else
                tag = '';
            end
        end
        
    end

end
