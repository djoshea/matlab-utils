classdef Cluster < handle & matlab.mixin.Copyable
	% Cluster (abstract)
	%
	% Basic cluster minimal operations
	%
	% Clusters that include display options should subclass from
	% DisplayableCluster.
	
	properties(Constant)
		ClusterFuncKey = 'ClusterFunc_';
	end
	
	properties(Access=public)
		name = 'Cluster'; % name
	end
	
	methods(Static, Access=public)
		function bool = Modifiable()
			bool=false;
		end
	end
	
	methods
		
		% constructor - all constructors are now expected to be empty
		% use set parms
		function self = Cluster()
		end
		
		function SetParms(self, varargin)
			if isa(varargin{1}, 'MClust.ClusterTypes.Cluster')
				self.name = varargin{1}.name;				
			else
				MClustUtils.process_varargin_class(self,varargin{:});
			end
		end
		
		%--------------------------------------
		% Access
		%--------------------------------------
		
		function S = GetSpikes(self) %#ok<MANU>
			% Return the list of spikes that are part of the cluster.
			% Should be redefined in Cluster class
			S = [];
		end
		
		function nS = nSpikes(self)
			% Return the list of spikes that are part of the cluster.
			% Should be redefined in Cluster class
			nS = length(self.GetSpikes());
		end
		function T = GetSpikeTimes(self)
			MCD = MClust.GetData();
			mySpikes = self.GetSpikes();
			T = ts(MCD.FeatureTimestamps(mySpikes));
		end
		function WV = GetWaveforms(self)
			MCD = MClust.GetData();
			mySpikes = self.GetSpikes();
			WV = MCD.LoadNeuralWaveforms(mySpikes, 2);
		end
		
		function RenameCluster(self, name)
			self.name = name;
		end
		
		function copy = MakeCopy(self)
			myClass = class(self);
			copy = feval(myClass);
			P = properties(self);
			for iP = 1:length(P)
				metaproperties = findprop(self, P{iP});
				if ~metaproperties.Constant
					eval(['copy.' P{iP} '=' 'self.' P{iP} ';']);
				end
			end
		end
		
		function copy = Convert(self, newClass)
			copy = feval(newClass);
			copy.SetParms(self);
		end
		
		%-------------------------------
		% AVAILABLE FUNCS
		%-------------------------------
		function R = FindClusterFunctions(self)
			m = methods(self);
			clusterfuncs = strncmp(self.ClusterFuncKey, m, length(self.ClusterFuncKey));
			R = m(clusterfuncs);
			for iR = 1:length(R)
				R{iR} = R{iR}((length(self.ClusterFuncKey)+1):end);
			end
		end
		
		function CallClusterFunction(self, cfn)
			feval([self.ClusterFuncKey cfn], self);
		end
		
	end
end
