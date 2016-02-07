classdef DisplayableCluster < MClust.ClusterTypes.Cluster
    % DisplayableCluster (abstract)
    
    properties(SetObservable)        
        % for display
        hide = false;
        color = [0 0 0];
        markerSize = 1;
        marker = '.';
        
        hideButton;
        colorButton;
    end
   
    properties(Access=protected)
        AssociatedCutterFunction = [];
    end
    
    properties(Access=public)
        ClusterFuncMenu;
	end
       
	
	methods(Static, Access=public)
		function bool = Modifiable()
			bool=false;
		end
	end

    methods        

		% ------------------------------------------
		% Constructor and properties
                
		function SetParms(self, varargin)
			if isa(varargin{1}, 'MClust.ClusterTypes.DisplayableCluster')
				self.color = varargin{1}.color;		
				self.AssociatedCutterFunction = varargin{1}.AssociatedCutterFunction;
				self.hide = varargin{1}.hide;
				self.color = varargin{1}.color;
				self.markerSize = varargin{1}.markerSize;
				self.marker = varargin{1}.marker;
			end
			self.SetParms@MClust.ClusterTypes.Cluster(varargin{:});
		end

		
        function RenameCluster(self, name)
            if nargin == 1
                name = inputdlg('Rename Cluster','Rename Cluster', 1, {self.name});
                name = name{1};
            end
            self.name = name;
        end
        
        function setAssociatedCutter(self, ACF)
            self.AssociatedCutterFunction = ACF;
        end            
        
        function MCC = getAssociatedCutter(self)
            MCC = feval(self.AssociatedCutterFunction);
        end
        
        function copy = MakeCopy(self)
            copy = self.MakeCopy@MClust.ClusterTypes.Cluster();			
			MCC = self.getAssociatedCutter();
			copy.setAssociatedCutter(@MCC.GetCutter);
            MCC.Clusters{end+1} = copy;
			MCC.ReGo();
		end

		function copy = Convert(self, newClass)
            copy = self.Convert@MClust.ClusterTypes.Cluster(newClass);			
			MCC = self.getAssociatedCutter();
			copy.setAssociatedCutter(@MCC.GetCutter);
			IAM = MCC.findSelf(self);
            MCC.Clusters{IAM} = copy;
			MCC.ReGo();
        end

        %-------------------------------
        % AVAILABLE FUNCS
        %-------------------------------
        function R = FindClusterFunctions(self)
            m = methods(self);
            clusterfuncs = strncmp(self.ClusterFuncKey, m, length(self.ClusterFuncKey));            
            R = m(clusterfuncs)';            
            for iR = 1:length(R)
                R{iR} = R{iR}((length(self.ClusterFuncKey)+1):end);
            end
        end
        
        function CallClusterFunction(self, cfn)
            if nargin==1 || cfn==0
                s = get(self.ClusterFuncMenu, 'String');
                v = get(self.ClusterFuncMenu, 'Value');
                cfn = s{v};
            end
            if streq(cfn, self.name)
                self.RenameCluster();
                s{1} = self.name;
                set(self.ClusterFuncMenu, 'String', s);
            else
                feval([self.ClusterFuncKey cfn], self);
            end
            if ishandle(self.ClusterFuncMenu)
                set(self.ClusterFuncMenu, 'Value', 1);
            end
        end
        
        %-------------------------------
        % CALLBACKS and DISPLAYS
        %-------------------------------
        function ChangeColor(self, color)
            % change the color of oneself
            if nargin==1
                self.color = uisetcolor(self.color);
            else
                self.color = color;
            end
            self.getAssociatedCutter().ReGo();
        end
        
        function ChangeHide(self, H)
            % change the color of oneself
            if nargin==1
                self.hide = ~self.hide;
            else
                self.hide = logical(H);
            end
            self.getAssociatedCutter().RedrawAxes();
        end
        
        function ChangeMarker(self, ~, ~)
           % change the marker being used
           s = get(gcbo, 'String');
           v = get(gcbo, 'Value');
           self.marker = s{v};
           self.getAssociatedCutter().RedrawAxes();
        end
        
         function ChangeMarkerSize(self, ~, ~)
           % change the marker being used
           s = get(gcbo, 'String');
           v = get(gcbo, 'Value');
           if ~isempty(s{v})
               self.markerSize = str2double(s(v));
           else
               self.markerSize = '';
           end
           self.getAssociatedCutter().RedrawAxes();
         end
         
         %----------------display self
        % assumes a thin linear panel

		function RemoveClusterFuncMenu(self)
			delete(self.ClusterFuncMenu);
			self.ClusterFuncMenu = [];
		end
					
    end
end

