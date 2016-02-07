classdef ZeroCluster < MClust.ClusterTypes.DisplayableCluster
    % returns all spikes
    
    properties(SetObservable)
        ShowUnaccountedForOnly = false;
    end
    
    methods(Static, Access=public)
        function bool = Modifiable()
            bool=false;
        end
    end
    
    methods
        % --------------------------- Constructor
        function self = ZeroCluster()
            self = self@MClust.ClusterTypes.DisplayableCluster();
            self.name = 'All Spikes';
            self.color = [0 0 0];
            self.markerSize = 1;
            self.marker = '.';
            self.hide = false;
        end
        
        % -------------------------- GetSpikes
        function S = GetSpikes(self)
            MCD = MClust.GetData();
            MCC = self.getAssociatedCutter();
            S = 1:length(MCD.FeatureTimestamps);
            if self.ShowUnaccountedForOnly
                keep = true(size(S));
                C = MCC.Clusters();
                for iC = 1:length(C)
                    if ~isequal(C{iC},self)
                        keep(C{iC}.GetSpikes()) = false;
                    end
                end
                S = S(keep);
            end
        end
        
        %------------------------------------------
        % New Callbacks
        %------------------------------------------
        function ChangeShowUnaccountedForOnly(self, H)
            if nargin==1
                self.ShowUnaccountedForOnly = ~self.ShowUnaccountedForOnly;
            else
                self.ShowUnaccountedForOnly = logical(H);
            end
            
            if self.ShowUnaccountedForOnly
                self.name = 'Unaccounted for Spikes';
            else
                self.name = 'All Spikes';
            end
            
            MCC = self.getAssociatedCutter();
            MCC.ReGo();
            
        end
        
        function ClusterFunc_02_DeleteCluster(self)
            msgbox('Cannot delete the Zero Cluster.');
        end
        %------------------------------------------
        % Display
        %------------------------------------------
        function DisplaySelf(self, panel0, iC)
            self.DisplaySelf@MClust.ClusterTypes.DisplayableCluster(panel0, iC);
            self.RemoveClusterFuncMenu();
            % unaccounted for
            uicontrol(panel0, 'Style', 'CheckBox', ...
                'Units', 'Normalized','Position', [0.3 0 0.6 1], ...
                'Value', self.ShowUnaccountedForOnly, ...
                'String', 'Unaccounted for only', ...
                'HorizontalAlignment', 'right', ...
                'Callback', @(src,event)ChangeShowUnaccountedForOnly(self));
        end
        
        %------------------------------------------
        % Check
        function CheckCluster(self)
            return
        end
        
    end
    
end

