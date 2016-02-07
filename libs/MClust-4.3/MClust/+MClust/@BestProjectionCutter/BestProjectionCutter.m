classdef BestProjectionCutter < MClust.Cutter
    % A subcutter for manual cutter.
    
    properties (Constant)
        maxUndoRedo = 10;
    end
    
    properties
        parent; % ManualCutter called from;
        PrimaryCluster;  % Cluster we are comparing to
		SecondaryCluster; % Comparison Cluster that has current focus

        % --- windows              
 
        % --- process
        Undo = MClustUtils.UndoSystem(MClust.BestProjectionCutter.maxUndoRedo);
        Redo = MClustUtils.UndoSystem(MClust.BestProjectionCutter.maxUndoRedo);
        
        % --- display windows
        
        % --- labels     
        primaryClusterPanel;
        projectionPath;
        
        undoButton; redoButton;
        
        % --- features
		FeatureX, FeatureY;   % projected features
    end
    
    methods
        
        function self = BestProjectionCutter(parent, iC, Features)
            
            self.parent = parent;
			self.importClusters();            
            self.PrimaryCluster = self.Clusters{iC};
			self.PrimaryCluster.hide = false;
            
			% features to work from - eventually a selection box
			self.Features = Features;  
			self.FeatureX = [];
			self.FeatureY = [];
			
			% redrawing
			set(self.redrawAxesButton, 'value', true);
            			
			% Go
			if (iC ~= 1)
				self.TakeFocus(self.Clusters{1});
			else
				self.TakeFocus(self.Clusters{2});
			end
			
        end
		
        function close(self)
            if ~isvalid(self), return; end

			self.close@MClust.Cutter();
		end

        
		%-----------------------------------------------------
		% import/export clusters
		%-----------------------------------------------------

		function importClusters(self)
			copiedClusters = cellfun(@(x)copy(x), self.parent.Clusters, 'UniformOutput', false);
			for iC = 1:length(copiedClusters)
				copiedClusters{iC}.setAssociatedCutter(@self.GetCutter);
				copiedClusters{iC}.hide = true;
			end
            self.Clusters = copiedClusters;        
			self.Clusters{1}.hide = false;
		end
		
		function exportClusters(self)		
			MCC = self.parent;
			copiedClusters = cellfun(@(x)copy(x), self.Clusters, 'UniformOutput', false);
			for iC = 1:length(copiedClusters)
				copiedClusters{iC}.setAssociatedCutter(@MCC.GetCutter);
			end
			self.parent.Clusters = copiedClusters;
			self.parent.ReGo();
		end
                
        %-----------------------------------------------------
        % internal information gathering
        %-----------------------------------------------------
		
		function xFeat = get_xFeature(self)
			xFeat = self.FeatureX;
		end

		function xFeat = get_yFeature(self)
			xFeat = self.FeatureY;
		end
		
        % ----------- redisplay
		
		function TakeFocus(self, C)
			self.SecondaryCluster = C;
			for iC = 1:length(self.Clusters)
				if ~isequal(self.Clusters{iC}, self.PrimaryCluster)
					self.Clusters{iC}.hide = true;
				end
			end
			C.hide = false;
			self.ReGo();
		end
		
		% ----------- redisplay
		function ReGo(self)
			self.RecalculateProjection();
			self.ReGo@MClust.Cutter();
		end

% 		function RedisplayAvgWV(self, C)
% 			WV0 = self.PrimaryCluster.GetWaveforms();
% 			MClust.AverageWaveform(WV0, ...
% 				'myFigureTag', figHandle_AvgWV, 'color','b', 'showSE', true);
% 			WV1 = C.GetWaveforms();
% 			MClust.AverageWaveform(WV1, ...
% 				'axesHandle', gca, 'color', 'r', 'showSE', false, 'LineWidth', 2)			
% 		end
% 		
% 		function RedisplayISI(self, C)
% 		end
% 
% 		function RedisplayXCorr(self, C)
% 		end
%         
        %----------------------------------------------------
        % CALLBACKS
		%----------------------------------------------------
		
        %------------ AXES
             
        %------------------- DISPLAY
        
        %------------------- MARKERS
        
        %----------------------- CLUSTERS
             
        %------------------------------------
        % UNDO/REDO
        %------------------------------------
        function StoreUndo(self, funcname)
			if nargin==1
				funcname = MClustUtils.myCallerName();
			end
            self.Undo.StoreUndo(self.Clusters, funcname);
            set(self.undoButton, 'ToolTip', ['Undo ' self.Undo.nextUndoName()]);
            set(self.redoButton, 'Tooltip', ['Redo ' self.Redo.nextUndoName()]);
        end
        
        function PopUndo(self)
            if (self.Undo.anythingToUndo)
                self.Redo.StoreUndo(self.Clusters, self.Undo.nextUndoName());
                self.Clusters = self.Undo.PopUndo;
                self.ReGo();
                set(self.undoButton, 'ToolTip', ['Undo ' self.Undo.nextUndoName()]);
                set(self.redoButton, 'Tooltip', ['Redo ' self.Undo.nextUndoName()]);
            end
        end
        
        function PopRedo(self)
            if (self.Redo.anythingToUndo)
                self.Undo.StoreUndo(self.Clusters, self.Redo.nextUndoName());
                self.Clusters = self.Redo.PopUndo;
                self.ReGo();
                set(self.undoButton, 'ToolTip', ['Undo ' self.Undo.nextUndoName()]);
                set(self.redoButton, 'Tooltip', ['Redo ' self.Undo.nextUndoName()]);
            end
        end
                
        %-------------------------------
        % AVAILABLE FUNCS
        %-------------------------------

        
    end
    
end

