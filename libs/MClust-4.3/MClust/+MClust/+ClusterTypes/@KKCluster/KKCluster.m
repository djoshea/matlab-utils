classdef KKCluster < MClust.ClusterTypes.DisplayableCluster
    % 
	% Cluster type for KlustaKwik selection cutter
	%
	%    This is an unmodifiable displayable cluster, that remembers
	%    whether it should be kept or not.
	%
	%    Because the spikelist cannot change, it remembers its 
	%    averagewaveform
    
    properties
		% key question: keep or not
        keep = false;
		mergeSet = '--';
		
		% spikes
		S = [];
		
		% stored data
		xrange = [];
		mWV = []; 
		sWV = [];	
        		
		% display
		keepButton;
		focusButton;
        comparisonButton;
		mergeSetButton;
	end
    
	methods(Access=private)
		function SetSpikes(self, S)
			self.S = S;
		end
		
		function SetAverageWaveform(self, WV)
            MCD = MClust.GetData();
            if isempty(WV)
                WV = MCD.LoadNeuralWaveforms(self.S, 2);
            end
			[self.mWV, self.sWV, self.xrange] = MClust.AverageWaveform(WV);
		end
	end
			
	
    methods
        % --------------------------- Constructor
        function self = KKCluster(name, color, S, WV)
			% requires name, color, list-of-spikes, and WV[tsd] as input
            self.SetParms('name', name, 'color', color);
			self.mergeSet = name;
			self.SetSpikes(S);
            self.SetAverageWaveform(WV);
        end
        
        % -------------------------- GetSpikes
        function S = GetSpikes(self)
			S = self.S;
        end
        
        %------------------------------------------
        % New Callbacks
        %------------------------------------------
		function ChangeKeep(self)
			self.keep = get(self.keepButton, 'Value');
            if self.keep
                set(self.keepButton, 'String', 'keep', 'ForeGroundColor', 'w', 'BackgroundColor', 'k');
            else
                set(self.keepButton, 'String', 'toss', 'ForeGroundColor', 'k', 'BackgroundColor', 'w');
            end
		end
		
		function TakeFocus(self)
			if all(self.color==[0 0 0])
				self.color = [0 0 1];
			end;
			KCC = self.getAssociatedCutter();
            KCC.SetFocus(self);
			self.markerSize = 5;
			set(self.focusButton, 'value', true);
            set(self.focusButton, 'string', 'Focus');
            self.TakeComparison();
			KCC.RedrawAxes();
			KCC.RedisplayAvgWV();
			KCC.RedisplayISI();
		end
		
		function LoseFocus(self, FocusC)
            if ~isempty(self.colorButton) && ishandle(self.colorButton)
                self.color = get(self.colorButton, 'BackgroundColor');
            else
                self.color = [0 0 0];
            end
			MCS = MClust.GetSettings();            
			self.markerSize = MCS.ClusterCutWindow_MarkerSize;
            
            % calculate correlation coefficient
            C = corrcoef(self.mWV(:), FocusC.mWV(:));
            C = C(1,2);          
            
			if ~isempty(self.focusButton) && ishandle(self.focusButton)
				set(self.focusButton, 'value', false);
                set(self.focusButton, 'string', sprintf('%2.1f',C));
			end
        end
        
        function TakeComparison(self)
			if all(self.color==[0 0 0])
				self.color = [1 0 0];
			end;
			KCC = self.getAssociatedCutter();
            KCC.SetComparison(self);
			self.markerSize = 5;
			set(self.comparisonButton, 'value', true);
			KCC.RedrawAxes();
			KCC.RedisplayAvgWV();
			KCC.RedisplayISI();
		end
		
		function LoseComparison(self, ~)
            if ~isempty(self.focusButton) && ishandle(self.focusButton) && get(self.focusButton, 'value') % has focus
                return;
            else % does not have focus
                if ~isempty(self.colorButton) && ishandle(self.colorButton)
                    self.color = get(self.colorButton, 'BackgroundColor');
                else
                    self.color = [0 0 0];
                end
                MCS = MClust.GetSettings();
                self.markerSize = MCS.ClusterCutWindow_MarkerSize;
                if ~isempty(self.comparisonButton) && ishandle(self.comparisonButton)
                    set(self.comparisonButton, 'value', false);
                end
            end
		end
		
        function bool = hasFocus(self)
            KCC = self.getAssociatedCutter();
            bool = logical(isequal(self, KCC.whoHasFocus));
        end
	
        function bool = hasComparison(self)
            KCC = self.getAssociatedCutter();
            bool = logical(isequal(self, KCC.whoHasComparison));
        end

		function ChangeMergeSet(self)
			self.mergeSet = get(self.mergeSetButton, 'string');
		end
		function s = getMergeSet(self)			
			s = self.mergeSet;
		end
		
        %------------------------------------------
        % Display
        %------------------------------------------
        function PanelSelf(self, panel0, iC)
            self.PanelSelf@MClust.ClusterTypes.DisplayableCluster(panel0, iC);
			self.RemoveClusterFuncMenu();
            % mergeSet
			self.mergeSetButton = ...
				uicontrol(panel0, 'Style', 'edit', ...
                'Units', 'Normalized','Position', [0.2 0 0.2 1], ...
                'String', self.mergeSet, ...
				'Callback', @(src,event)ChangeMergeSet(self), ...
                'HorizontalAlignment', 'center');         
            % keepIt
			self.keepButton = ... 
				uicontrol(panel0, 'Style', 'toggleButton', ...
                'Units', 'Normalized','Position', [0.4 0 0.25 1], ...
                'Value', self.keep, ...                
                'HorizontalAlignment', 'left', ...
                'Callback', @(src,event)ChangeKeep(self));         
            ChangeKeep(self);
			% take focus
			self.focusButton = ...
				uicontrol(panel0, 'Style', 'RadioButton', ...
                'Units', 'Normalized','Position', [0.65 0 0.20 1], ...
                'Value', false, ...
                'String', 'Focus', ...
                'HorizontalAlignment', 'left', ...
                'Callback', @(src,event)TakeFocus(self));   
            % comparisonbutton
			self.comparisonButton = ...
				uicontrol(panel0, 'Style', 'RadioButton', ...
                'Units', 'Normalized','Position', [0.85 0 0.05 1], ...
                'Value', false, ...
                'String', 'Focus', ...
                'HorizontalAlignment', 'left', ...
                'Callback', @(src,event)TakeComparison(self));   
            if self.hasFocus()
                self.TakeFocus();
            end
		end
		
		%------------------------------------------
		% Check
				
    end
    
end

