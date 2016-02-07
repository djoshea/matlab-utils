classdef SpikelistCluster < MClust.ClusterTypes.DisplayableCluster
    % keeps list of spikes
    
    properties(SetObservable)
        mySpikes = [];
	end
	
	methods(Static, Access=public)
		function bool = Modifiable()
			bool=true;
		end
	end
   
    methods
		
        % --------------------------- Constructor
		function SetParms(self, varargin)
			self.SetParms@MClust.ClusterTypes.DisplayableCluster(varargin{:});
			if isa(varargin{1}, 'MClust.ClusterTypes.Cluster')
				self.mySpikes = varargin{1}.GetSpikes();
			end
		end
	
	% -------------------------- GetSpikes
        function S = GetSpikes(self)
            S = self.mySpikes;
        end
        
        function SetSpikes(self, S)
            self.mySpikes = S;
        end
        
        function AddSpikes(self, S0)
			% input = list of spikes (aligned to total set)
            MCD = MClust.GetData();
            assert(max(S0) <= length(MCD.FeatureTimestamps));
            self.mySpikes = union(self.mySpikes, S0);
        end
        
        function RemoveSpikes(self, S0)
			% input = list of spikes (aligned to total set)
            self.mySpikes = setdiff(self.mySpikes, S0);
        end
        
        function LimitSpikes(self, S0)
            % input = list of spikes aligned to total set
            self.mySpikes = intersect(self.mySpikes, S0);
        end
		
       
        %------------------------------------------
        % New Callbacks
        %------------------------------------------

        %------------------------------------------
        % Display
        %------------------------------------------
		
    end
    
end

