classdef MClustMainWindowClass < handle
    % Main window of the MClust program
    %
    %
    % ADR 2012/12
    
    properties(Constant)
        AboutString = {[MClustSettings.VERSION], 'By AD Redish', ' ', ...
            ' including code by ', 'F Battaglia',  'S Cowen', 'JC Jackson', 'P Lipa','NC Schmitzer-Torbert',  ...
            ' ', ' KlustaKwik by K. Harris'}
    end
    
    properties(Access=protected)
        BeingDeleted=false;
    end

    properties(Access=public)
        MClustMainFigureHandle;
        
        LoadingEngines = {};
        LoadingEngineValue = [];
        
        % uicontrols
        LoadingEnginePulldown;
		nClustersText;
        LoadProfileButton;
        SaveProfileButton
        TTfnLabel;
        FDCheckBox
        FeatureListBoxes;
        NormalizeFeaturesButton;
        ChannelValidityButton;
        t_tButton
        
        %Cutters
        MCC = []; % Manual Cutter
		KCC = []; % KKwik Cutter
        
    end
    
    methods
        % constructor
        function self = MClustMainWindowClass(MCS, MCD)
            self.CreateMainWindow(MCS, MCD);
        end
        
        % destructor
        function delete(self)
            self.ExitMClust();
		end        
		
		% close cutters
		function CloseCutters(self)
			if ~isempty(self.KCC) && isvalid(self.KCC)
				self.KCC.close();
				self.KCC = [];
			end
			if ~isempty(self.MCC) && isvalid(self.MCC)
				self.MCC.close();
				self.MCC = [];
			end
		end
    end
    
    methods(Access=protected)
        
        %----------- Loading Engines -----------------------
        function self = FindCurrentLoadingEngine(self)
            MCS=MClust.GetSettings();
            if ~isempty(MCS.NeuralLoadingFunction)
                self.LoadingEngineValue = find(strncmp(MCS.NeuralLoadingFunction,self.LoadingEngines,length(MCS.NeuralLoadingFunction)));
            end
            if isempty(self.LoadingEngineValue)
                self.LoadingEngineValue = 1;
                MCS.NeuralLoadingFunction = self.LoadingEngines{1};
            end
        end
        
        function self = FindAvailableLoadingEngines(self)
            MCS=MClust.GetSettings();
            LoadingEngineDirectory = fullfile(MCS.Directory, 'LoadingEngines');
            
            LoadingEnginesM = FindFiles('*.m', 'StartingDirectory', LoadingEngineDirectory, 'CheckSubdirs', false);
            LoadingEnginesMex = FindFiles(['*.', mexext], 'StartingDirectory', LoadingEngineDirectory, 'CheckSubdirs', false);
            self.LoadingEngines = sort(cat(1, LoadingEnginesM, LoadingEnginesMex));
            
            for iV = 1:length(self.LoadingEngines)
                [~, self.LoadingEngines{iV}] = fileparts(self.LoadingEngines{iV});
            end
            self.LoadingEngines = unique(self.LoadingEngines);
            assert(~isempty(self.LoadingEngines), 'No Loading Engines found.');
            self = FindCurrentLoadingEngine(self);
        end
    end
    
    methods(Access=public)
        
        %----------- Features ------------------------------
        function self = ChangeFeaturesToUse(self)
            MCS=MClust.GetSettings(); MCD = MClust.GetData();
            MCS.FeaturesToUse = self.FeatureListBoxes.GetRightList();
			if MCD.DataLoaded()
				MCD.FillFeatures();
			end
		end
        		
		function ResetClusterText(self)
			MCD = MClust.GetData();
			if MCD.nSpikes == 0
				set(self.nClustersText, 'String', '');
			else				
				set(self.nClustersText, 'String', sprintf('%d Clusters', length(MCD.Clusters)));
			end
		end
        %--------------------------------------------------------------
        %     CALLBACKS
		%--------------------------------------------------------------
		function ExitMClust(self, ~, ~)
			if self.BeingDeleted, return; else self.BeingDeleted=true; end
			MCS = MClust.GetSettings();
			MCD = MClust.GetData();
			if ~isempty(MCD.Clusters) && ~MCD.FilesWrittenYN
				ynWrite = questdlg('Are you sure? T-files not saved.', 'ExitQuestion', 'Yes','Cancel', 'Cancel');
				if streq(ynWrite, 'Cancel'), return; end
			end
			
			if ishandle(self.MClustMainFigureHandle)
				delete(self.MClustMainFigureHandle);
			end
			
			self.CloseCutters();		
			
			delete(MCD);
			delete(MCS);
			
			% clear the MClust instance in global space
			clear global MClustInstance
		end
		
		function SelectLoadingEngine(self,~,~)
            MCS=MClust.GetSettings();
            MCD=MClust.GetData();
            % changes NeuralLoadingFunction
            value = get(self.LoadingEnginePulldown, 'Value');
            MCS.NeuralLoadingFunction = self.LoadingEngines{value};

            %-----------------------------------------------------
            try  % New Loading Engine functionality ADR 22 Jan 2014
                % loading engine defines channel validity and expected
                % extenions
                CV = feval(MCS.NeuralLoadingFunction, 'get', 'ChannelValidity');
                self.SetChannelValidity(CV);
            catch ME
            end
            
            try
                xt = feval(MCS.NeuralLoadingFunction, 'get', 'ExpectedExtension');
                MCD.TText = xt;
            catch ME
            end
            
            try
                MCS.UseFileDialog = true; % default to True
                fd = feval(MCS.NeuralLoadingFunction, 'get', 'UseFileDialog');
                MCS.UseFileDialog = fd;
            catch ME
            end
            %---------------------------------------------------------
                
        end
        
        function LoadTetrodeData(self,~,~)
            MCD = MClust.GetData();
            MCS = MClust.GetSettings();
            MCD.LoadTetrodeData(MCS.UseFileDialog);
            self.Redraw()
        end
        
        function ChangeChannelValidity(self,~,~)
            MCS = MClust.GetSettings();
            assert(MCS.nCh == length(self.ChannelValidityButton), 'nCh does not match Channel Validity');
            assert(MCS.nCh == length(MCS.ChannelValidity), 'nCh does not match Channel Validity');
            for iV = 1:MCS.nCh
                MCS.ChannelValidity(iV) = get(self.ChannelValidityButton{iV}, 'Value');
            end
        end
 
        function SetChannelValidity(self,CV)
            MCS = MClust.GetSettings();
            assert(length(CV) == length(self.ChannelValidityButton), 'passed in ChannelValidty does not match expected length.');
            assert(MCS.nCh == length(self.ChannelValidityButton), 'nCh does not match Channel Validity');
            assert(MCS.nCh == length(MCS.ChannelValidity), 'nCh does not match Channel Validity');
            for iV = 1:length(CV)
                set(self.ChannelValidityButton{iV}, 'Value', CV(iV));
                MCS.ChannelValidity(iV) = CV(iV);
            end
        end

        function ChangeT_T(self)
            MCS = MClust.GetSettings();
            MCS.UseUnderscoreT = get(self.t_tButton, 'Value');
		end
		
        function RunManualCutter(self)
            if isempty(MClust.GetData().FeatureTimestamps)
                warning('MCLUST:noDataLoaded', 'No data loaded.  Cannot start Cutter.');
            elseif isempty(self.MCC) || ~isvalid(self.MCC)
                self.MCC = MClust.ManualCutter();
            else
                self.MCC.GetFocus();
            end
		end

        function RunKKwikCutter(self)
            if isempty(MClust.GetData().FeatureTimestamps)
                warning('MCLUST:noDataLoaded', 'No data loaded.  Cannot start Cutter.');
            elseif isempty(self.KCC) || ~isvalid(self.KCC)
                self.KCC = MClust.KKwikCutter();
            else
                self.KCC.GetFocus();
            end
        end
		
        function LoadProfile(self,~,~)
            MCS=MClust.GetSettings();
            % changes settings
            fn = uigetfile('*.mclust', 'Load Profile', 'defaults.mclust');
            if ~isequal(fn, 0)
                MCS.load(fn);
                self = self.FindCurrentLoadingEngine();
                Redraw(self)
            end
        end
        
        function SaveProfile(~,~,~)
            MCS=MClust.GetSettings();
            % changes settings
            fn = uiputfile('*.mclust', 'Save Profile', 'defaults.mclust');
            if ~isequal(fn, 0)
                MCS.save(fn);
            end
        end
        
        function ClearWorkspace(self,~,~)    
            global MClustInstance
            ynClear = questdlg('Clearing workspace cannot be undone.  Are you sure?', 'ExitQuestion', 'Yes','Cancel', 'Cancel');
            if streq(ynClear, 'Cancel'), return; end

            MClustInstance.ClearWorkspace();
            self.Redraw();
        end
        
        % -------------------- Loading and Saving Clusters		
        function SaveClusters(self, ~, ~) %#ok<MANU>
            MCD = MClust.GetData();
            MCD.SaveClusters();
        end

        function LoadClusters(self, ~, ~) %#ok<MANU>
            MCD = MClust.GetData();
            MCD.LoadClusters();
        end
      
        function ApplyConvexHulls(self, ~, ~)  %#ok<MANU>
            MCD = MClust.GetData();
            MCD.ApplyConvexHullsFromFile();
        end
        
        function ClearClusters(self, ~, ~) %#ok<MANU>
            ynClear = questdlg('Clearing clusters cannot be undone.  Are you sure?', 'ExitQuestion', 'Yes','Cancel', 'Cancel');
            if streq(ynClear, 'Cancel'), return; end            
            MCD = MClust.GetData();
            MCD.ClearClusters();
        end 
        
        % ----------------------- Writing T files
        function WriteTfiles(self, ~, ~) %#ok<MANU>
            MCD = MClust.GetData();
            MCD.SaveClusters(MCD.DefaultClusterFileName);
            OK = MCD.WriteTfiles();   
            if OK
                disp('T files written.');
				MCD.FilesWrittenYN = true;
            end
        end
        
        function WriteTWVCQfiles(self, ~, ~)
            self.WriteTfiles();
            MCD = MClust.GetData();
            OK = MCD.WriteWVfiles();
            if OK
                OK = OK && MCD.WriteCQfiles();
                if OK
                    disp('WV and CQ files written.');
                    MCD.FilesWrittenYN = true;
                end
            end
        end
        
        function EraseTfiles(self, ~, ~) %#ok<MANU>
            MCD = MClust.GetData();
            OK = MCD.EraseTfiles();   
            if OK
                disp('T, _T, WV, CQ files erased.');
            end
        end
    
    end      
end