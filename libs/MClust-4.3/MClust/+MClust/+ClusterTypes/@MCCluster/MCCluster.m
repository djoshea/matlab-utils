classdef MCCluster < MClust.ClusterTypes.CvxHullCluster & MClust.ClusterTypes.SpikelistCluster
    % Basic MCCluster
    % 
    % the type we had in MClust 3.5
       	
	methods(Static, Access=public)
		function bool = Modifiable()
			bool=true;
		end
	end

    methods        
        function S = GetSpikes(self)
            S = self.LimitSpikes(self.mySpikes);
		end
		
		function SetParms(self, varargin)			
			self.SetParms@MClust.ClusterTypes.SpikelistCluster(varargin{:});
		end
           
        %-------------------------------
        % Split functions
        %-------------------------------
        function S = LimitSpikes(self, S0)
            S = self.LimitSpikes@MClust.ClusterTypes.CvxHullCluster(S0);
        end
        %-------------------------------
        % CALLBACKS and DISPLAYS
        %-------------------------------
			
    end
end

