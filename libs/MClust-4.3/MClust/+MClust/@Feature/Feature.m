classdef Feature
	
	% Feature - 
	%
	% this version keeps the feature on disk and only loads as necessary
	
	properties(Access=public)
		normalizedYN = false;
		
		fdFile = '';
		fdColumn = nan;
		name = '';
		
		inMemory = false;
		FD; 
	end
	
	methods
		% call as Feature(name, FD) or as Feature(name, fdFile, fdColumn)
		function self = Feature(name, varargin)
			MCS = MClust.GetSettings();
            
			self.name = name;
			switch length(varargin)
				case 0 % Feature(name)
					error('MClust:Feature', 'Called with inadequate information.');
				case 1 % Feature(name, FD)
					self.FD = varargin{1};
					self.inMemory = true;
					self.fdFile = '';
					self.fdColumn = '';
				case 2 % Feature(name, fdFile, fdColumn)
					self.fdFile = varargin{1};
					self.fdColumn = varargin{2};
					self.inMemory = false;
				otherwise
					error('MClust:Feature', 'Called with too much information.');
			end
		end

		function FD = GetData(self)
			if self.inMemory
				FD = self.FD;
			else
				if isempty(self.fdFile)
					error('MClust:Feature', 'Unloaded feature: %s', self.name);
				else
					load(self.fdFile, 'FeatureData', '-mat');
					FD = FeatureData(:,self.fdColumn);				 %#ok<NODEF>
				end
			end
		end
					
		function bool = isNormalized(self)
			bool = self.normalizedYN;
		end			
		
	end
end