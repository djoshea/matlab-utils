classdef (Sealed) MClust0 < handle
    
    % Internal class for MClust
    %
    % There can only be one element of this class
    
    properties
        Settings = [];
        Data = [];
        MainWindow = [];
    end
    
    methods
        function self = MClust0()						
        end
        
        function delete(self)
            if ~isempty(self.MainWindow)
                delete(self.MainWindow)
            end
        end
        
        function Initialize(self, withDisplay)
			if nargin==1, withDisplay=true; end
            self.Settings = MClustSettings();
            self.Data = MClustData(self.Settings);
			if withDisplay
				self.MainWindow = MClustMainWindowClass(self.Settings, self.Data);
			end
        end
               
        function bool = IsOK(self)
            bool = ...
                ~isempty(self.Settings) && isa(self.Settings, 'MClustSettings') && ...
                ~isempty(self.Data) && isa(self.Data, 'MClustData') && ...
                ~isempty(self.MainWindow) && isa(self.MainWindow, 'MainWindow');
        end
        
        function ClearWorkspace(self)
            % settings do not change
            
			% close any cutters
			self.MainWindow.CloseCutters();
			
            % reset data
            self.Data.Reset();				

        end
                
    end
end