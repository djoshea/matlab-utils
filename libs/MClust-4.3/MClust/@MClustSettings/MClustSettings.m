classdef (Sealed) MClustSettings < handle
    % Settings used in MClust
    %
    % ADR 2012/12
    %
    % contains parameters that do not change from tetrode cycle to cycle
    
    properties(Constant)
        VERSION = MClustVersion();
    end
    
    properties(Access = public)
        % constants
        DEBUG = true;
        Directory = fileparts(which('MClust.m'));
        
        tEXT = 't'; 
          % 't64' writes 64-bit data, after converting to 0.1 ms resolution
          % 't32' writes 32-bit data, after converting to 0.1 ms resolution
          % 't' writes 32-bit data, after converting to 0.1 ms resolution
          % 'raw64' writes 64-bit data with no conversion to 0.1 ms resolution
          % 'raw32' writes 32-bit data with no conversion to 0.1 ms resolution
                        
        % windows
        windowLocations = containers.Map;
        
        % -- display
        AverageWaveform_ylim = 16*[-2100 2100];  % For Cheetah 5        
        %AverageWaveform_ylim = [-2100 2100]; % For earlier versions of Cheetah
        
        colors = [];
        ClusterCutWindow_Marker = 1;
        ClusterCutWindow_MarkerSize = 1;
        ClusterCutWindow_MarkerList = {'.','o','x','+','*','s','d','v','^','<','>','p','h'};
        ClusterCutWindow_MarkerSizeList = {1,2,3,4,5,10,15,20,25};
        
        ClusterCutWindow_Pos= [10 60 450 650];
        CHDrawingAxisWindow_Pos= [500 200 650 650];
        
        % process
        NeuralLoadingFunction = 'LoadTT_NeuralynxNT'; % Loading Engine
        
        FeaturesAvailable = {};
        FeaturesToUse = {'feature_Peak', 'feature_Time'};
        
        normalizeYN = false; 
        nCh = nan;  % will be filled with length of ChannelValidity in constructor
        ChannelValidity = true(4,1);% nCh x 1 array of channel on (1) or off (0) flags
        
        DeletableFigureTag = 'MClustFigureTag';
        StartingClusterType = 'SpikelistCluster';
        
        % load-and-save
        defaultTText = '.ntt';
        defaultFDext = '.fd';
        defaultCLUSText = '.clusters';
        
        UseUnderscoreT = false;
        UseFileDialog = true;

        % clusterSeparation
        ClusterSeparationFeatures = {'feature_Energy','feature_WavePC1'};
        
    end
    
    %===========================================================
    methods
        function self = MClustSettings()
            self.nCh = length(self.ChannelValidity);
			if MClustData.maxClusters+1 < 100
				c = colormap(hsv(100));
				ix = mod((1:100),10)*10 + floor((1:100)/10);
				ix = ix(end:-1:1);
				self.colors = c(ix,:);
			else
				self.colors = colorcube(MClustData.maxClusters+1); 
			end
			close;
            self.resizeWindows();
            self.FindFeatures();            
        end
     end
    
    %===========================================================
    methods(Access = protected)
        
        % ---------------------------------------------------
        function resizeWindows(self) %#ok<MANU>
            % resize windows if necessary
            ScSize = get(0, 'ScreenSize');
            maxX = ScSize(3); %#ok<NASGU>
            maxY = ScSize(4); %#ok<NASGU>
            WindowList = {};
            WindowList{end+1} = 'self.ClusterCutWindow_Pos';
            WindowList{end+1} = 'self.CHDrawingAxisWindow_Pos';
            
            for iW = 1:length(WindowList)
                if eval(['sum(' WindowList{iW} '([1 3])) > maxX'])
                    eval([WindowList{iW} '([1 3]) = [maxX - 500 400];']);
                end
                if eval(['sum(' WindowList{iW} '([2 4])) > maxY'])
                    eval([WindowList{iW} '([2 4]) = [maxY - 500 400];']);
                end
            end
            
        end
        
        %-----------------------------------------------------
        function FindFeatures(self)
            featureFiles =  sort(FindFiles('feature_*.m', ...
                'StartingDirectory', fullfile(self.Directory, 'Features'),...
                'CheckSubdirs', 0));
            for iF = 1:length(featureFiles)
                [~, featureFiles{iF}] = fileparts(featureFiles{iF});
            end
            self.FeaturesAvailable = featureFiles;
        end
  
        %-----------------------------------------------------
        function ReconcileFeatures(self)
            self.FindFeatures();
            self.FeaturesToUse = intersect(self.FeaturesAvailable, self.FeaturesToUse);
        end
        
    end
    
    %===========================================================
    methods(Access = public)
        
        % load
        function load(self, fn)
            if nargin==1
                fn = 'defaults.mclust';
            end
            if exist(fn, 'file')
                load(fn, 'X', '-mat');
            elseif exist(fullfile(self.Directory, fn), 'file')
                load(fullfile(self.Directory, fn), 'X', '-mat');
            else
                fprintf('%s not found, using current settings.', fn);
                return;  % can't find file, don't change Settings
            end
            
            P = properties(self);
            for iP = 1:length(P)
                metaproperties = findprop(self, P{iP});
                if metaproperties.Constant
                    fprintf('%s is a CONSTANT property.  Not changing it on load.\n', P{iP});
                else
                    eval(['self.' P{iP} ' = X.' P{iP} ';']);
                end
            end
            self.ReconcileFeatures();
        end
        
        % save
        function save(self, fn)
            % uses temporary structure X
            if nargin==1, fn = 'defaults.mclust'; end
            P = properties(self);
            for iP = 1:length(P)
                eval(['X.' P{iP} ' = self.' P{iP} ';']);
            end
            save(fn, 'X', '-mat');
        end
        
    end
    
end
