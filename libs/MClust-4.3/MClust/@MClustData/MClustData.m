classdef MClustData < handle
    % Settings used in MClust
    %
    % ADR 2012/12
    %
    % contains data used in MClust that does change on a tetrode to tetrode
    % cycle
    
    
    properties(Constant)
        maxClusters = 98;
    end
    
    properties(Access = public)
        % constants
        
        % -- fileparts
        TTfn = '';       % file name for tt file
        TTdn = '';      % directory name for tt file
        FDdn = '';        % directory name for fd file
        TText = '.ntt';
        FDext = '.fd';
        
        % -- data
        Features = {};
        FeatureTimestamps = []; % timestamps
        
        % --- process
        FilesWrittenYN = false;
        
    end
    
    properties(SetObservable, Access=public)
        % -- clusters
        Clusters = {};
    end        
      
    %===========================================================
    methods % constructor
        function self = MClustData(MCS)
            self.TText = MCS.defaultTText;
            self.FDext = MCS.defaultFDext;
            
		end               
		
		function Reset(self)
			self.Features = {};
			self.FeatureTimestamps = []; % timestamps
			self.Clusters = {};
			self.TTfn = '';		
		end

	end
	
    
    methods         
		
	    % ----- Data loaded
		function B = DataLoaded(self)
			B = ~isempty(self.TTfn);
		end
		
        % ----- Loading/Saving/Clusters
        function C = AddCluster(self, C)
            if length(self.Clusters)<self.maxClusters
                self.Clusters{end+1} = C;
            else 
                C = [];
            end
        end
        
        function fn = DefaultClusterFileName(self)
            MCS = MClust.GetSettings();
            fn = fullfile(self.TTdn, [self.TTfn MCS.defaultCLUSText]);
        end
        
        function fn = TfileBaseName(self, iC)
            % returns without extension
            basefn = fullfile(self.TTdn, self.TTfn);
            fn = [basefn '_' num2str(iC,'%02.0f')];
        end
        
        function SaveClusters(self, fn)
            MCS = MClust.GetSettings();
            if nargin==1
                [fn,fd] = uiputfile(['*' MCS.defaultCLUSText], ...
                    'Save Clusters', self.DefaultClusterFileName);			
				fn = fullfile(fd,fn);
			end
            if ~isequal(fn, 0)
                Clusters = self.Clusters; %#ok<NASGU>
                save(fn, 'Clusters', '-mat');
            end
        end

        function LoadClusters(self)
            MCS = MClust.GetSettings();
            [fn,fd] = uigetfile(['*' MCS.defaultCLUSText], ...
                'Load Clusters', ['*' MCS.defaultCLUSText]);
            if ~isequal(fn, 0)
                load(fullfile(fd,fn), 'Clusters', '-mat');
                self.Clusters = Clusters; %#ok<CPROP>
            end
        end
        
        function ClearClusters(self)
            self.Clusters = {};
        end
        
        % ----------- Internal gets
        function n = nSpikes(self)
            n = length(self.FeatureTimestamps);
        end

    end
end