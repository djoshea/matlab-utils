classdef CvxHullCluster < MClust.ClusterTypes.DisplayableCluster
	% Convex Hull Cluster
	%
	% the type we had in MClust 2.0
	
	properties(SetObservable)
		%
		featuresX = {};
		featuresY = {};
		xg = {}; % limits
		yg = {};
	end
	
	methods(Static, Access=public)
		function bool = Modifiable()
			bool=true;
		end
	end
	
	methods
		
		%--------------------------------
		% Constructor
		
		%----------------------
		% access functions
		function nL = nLimits(self)
			nL = length(self.featuresX);
		end
		
		function S = GetSpikes(self)
			MCD = MClust.GetData();
			S = 1:MCD.nSpikes;
			S = self.LimitSpikes(S);
		end
		
		%-------------------------------
		% AVAILABLE FUNCS
		%-------------------------------
		function S = LimitSpikes(self, S)
			if nargin==1
				S = self.GetSpikes();
			end
			nLimits = length(self.featuresX);
			for iF = 1:nLimits
				xFD = self.featuresX{iF}.GetData();
				yFD = self.featuresY{iF}.GetData();
				OK = inpolygon(xFD(S), yFD(S), self.xg{iF}, self.yg{iF});
				S = S(OK);
			end
		end
		
		function iL = findLimit(self, xF, yF)
			nLimits = length(self.featuresX);
			for iL = 1:nLimits
				if isequal(self.featuresX{iL},xF) && isequal(self.featuresY{iL},yF)
					return;
				end
			end
			% didn't find any
			iL = [];
		end
		
		%-------------------------------
		% CALLBACKS and DISPLAYS
		%-------------------------------
		
	end
end

