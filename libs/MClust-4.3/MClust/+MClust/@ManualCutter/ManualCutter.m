classdef ManualCutter < MClust.Cutter
    % ManualCutter
    
    properties (Constant)
        nStepToAutosave = 10;
        maxUndoRedo = 10;
    end
    
    properties
        % --- windows
        
        % --- process
        Autosave = MClust.ManualCutter.nStepToAutosave; % countdown, when reaches 0 autosaves
        Undo = MClustUtils.UndoSystem(MClust.ManualCutter.maxUndoRedo);
        Redo = MClustUtils.UndoSystem(MClust.ManualCutter.maxUndoRedo);
        
        % --- labels
        clusterTypeToAddMenu;
        addClusterButton;
        undoButton; redoButton;
        autosaveButton;
        
        % --- clusters
		ClusterTypeToAdd = [];

    end
    
    methods
        
        function self = ManualCutter()
			self.importClusters();
			self.ReGo();
		end
		
		%-----------------------------------------------------
		% import/export clusters
		%-----------------------------------------------------

		function importClusters(self)
			MCD = MClust.GetData();
			Cluster0 = MClust.ClusterTypes.ZeroCluster();			
			copiedClusters = cellfun(@(x)copy(x), MCD.Clusters, 'UniformOutput', false);
			self.Clusters = cat(2, {Cluster0}, copiedClusters);
			for iC = 1:length(self.Clusters)
				self.Clusters{iC}.setAssociatedCutter(@self.GetCutter);
			end
		end
		
		function exportClusters(self)
			self.exportClusters@MClust.Cutter(self.Clusters(2:end));
		end
                
        %-----------------------------------------------------
        % internal information gathering
        %-----------------------------------------------------
        % ----------- redisplay
        
        %----------------------------------------------------
        % CALLBACKS
		%----------------------------------------------------
		
        %------------ AXES
             
        %------------------- DISPLAY
        
        %------------------- MARKERS
        
        %----------------------- CLUSTERS
        function ChangeClusterTypeToAdd(self, ~, ~)
            s = get(self.clusterTypeToAddMenu, 'String');
            v = get(self.clusterTypeToAddMenu, 'Value');
            self.ClusterTypeToAdd = s{v};
            
            set(self.addClusterButton, 'String', ['Add ', s{v}]);
        end
        
        function AddCluster(self, ~, ~)
			MCS = MClust.GetSettings();
            self.StoreUndo('Add Cluster');
            iC = length(self.Clusters)+1;			
            C = feval(['MClust.ClusterTypes.' self.ClusterTypeToAdd]);
            C.setAssociatedCutter(@self.GetCutter);
            C.name = ['Cluster ' num2str(iC,'%02.0f')];
            C.color = MCS.colors(iC+1,:);			
            if ~isempty(C)
				self.Clusters{end+1} = C;
                self.ReGo();
            end
        end
        
        function PackClusters(self, ~, ~)
            MCD = MClust.GetData(); C = self.Clusters;
            keep = true(size(C));
            for iC = 1:length(C)
                keep(iC) = C{iC}.nSpikes>0;
            end
            self.Clusters = self.Clusters(keep);
            self.ReGo();
        end
       
        function SaveAutosave(self, ~, ~) 
            MCS = MClust.GetSettings(); MCD = MClust.GetData();
            fn = fullfile(MCD.TTdn, ['Autosave' MCS.defaultCLUSText]);
            self.SaveClusters(fn);
            self.Autosave = self.nStepToAutosave;
            set(self.autosaveButton, 'String', ['Autosave in ' num2str(self.Autosave)]);
        end
        
        function SaveClusters(self, fn) 
			MCS = MClust.GetSettings(); MCD = MClust.GetData();
            if nargin==1
                [fn,fd] = uiputfile(['*' MCS.defaultCLUSText], ...
                    'Save Clusters', MCD.DefaultClusterFileName);
                fn = fullfile(fd, fn);
            end
            if ~isequal(fn, 0)
                Clusters = self.Clusters(2:end); %#ok<NASGU>
                save(fn, 'Clusters', '-mat');
			end
        end
        
        function LoadClusters(self)
            MCS = MClust.GetSettings();MCD = MClust.GetData();
            [fn,fd] = uigetfile(['*' MCS.defaultCLUSText], ...
                'Load Clusters', ['*' MCS.defaultCLUSText]);
            if ~isequal(fn, 0)
                load(fullfile(fd,fn), 'Clusters', '-mat');
                self.Clusters = cat(2, self.Clusters(1), Clusters);
			end
			self.ReGo();
        end
        
        function ClearClusters(self, ~, ~) 
            self.Clusters(2:end) = [];
			self.ReGo();
        end
        
        %------------------------------------
        % UNDO/REDO/Autosave
        %------------------------------------
        function StoreUndo(self, funcname)
			if nargin==1
				funcname = MClustUtils.myCallerName();
			end
            self.StepAutosave();
            self.Undo.StoreUndo(self.Clusters, funcname);
            set(self.undoButton, 'ToolTip', ['Undo ' self.Undo.nextUndoName()]);
            set(self.redoButton, 'Tooltip', ['Redo ' self.Redo.nextUndoName()]);
        end
        
        function PopUndo(self)
            if (self.Undo.anythingToUndo)
                self.StepAutosave();
                self.Redo.StoreUndo(self.Clusters, self.Undo.nextUndoName());
                self.Clusters = self.Undo.PopUndo;
                self.ReGo();
                set(self.undoButton, 'ToolTip', ['Undo ' self.Undo.nextUndoName()]);
                set(self.redoButton, 'Tooltip', ['Redo ' self.Undo.nextUndoName()]);
            end
        end
        
        function PopRedo(self)
            if (self.Redo.anythingToUndo)
                self.StepAutosave();
                self.Undo.StoreUndo(self.Clusters, self.Redo.nextUndoName());
                self.Clusters = self.Redo.PopUndo;
                self.ReGo();
                set(self.undoButton, 'ToolTip', ['Undo ' self.Undo.nextUndoName()]);
                set(self.redoButton, 'Tooltip', ['Redo ' self.Undo.nextUndoName()]);
            end
        end
        
        function StepAutosave(self)
            self.Autosave = self.Autosave - 1;
            if self.Autosave==0
                self.SaveAutosave;
            end
            set(self.autosaveButton, 'String', ['Autosave in ' num2str(self.Autosave)]);
        end
        
        %-------------------------------
        % AVAILABLE FUNCS
        %-------------------------------

        
    end
    
end

