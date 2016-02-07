classdef Cutter < handle
	% Cutter superclass
	
	properties (Constant)
		CutterFuncKey = 'CutterOption_';
		uicHeight = 0.05;
		uicWidth  = 0.175;
		uicWidth0 = 0.075;
		uicWidth1 = 0.10;
		XLocs = [0.05 0.40:MClust.Cutter.uicWidth1:0.9];
		dY = 0.05;
		YLocs = 0.95:-MClust.Cutter.dY:0.05;	

	end
	
	properties
		% --- windows
		CC_figHandle = [];
		CC_displayWindow = [];
		
		% --- labels
		xAxisLB;
		yAxisLB;
		axisMarkerSelect;
		axisMarkerSize;
		redrawAxesButton;
		
		uiScrollbar;
		clusterPanel;
		cutterFuncMenu;
		append;
		
		% --- data
		Features = [];
		
		% --- clusters
		Clusters = {};		
	end
	
	methods
		
		% constructor/destructors
		function self = Cutter()
			MCD = MClust.GetData();
			self.Features = MCD.Features;
			self.CreateCutterWindow();
		end
		
		function self = GetCutter(self)
		end
		
		function close(self)					
			if ~isvalid(self), return; end
            
            mainFigHandleToClose = self.CC_figHandle;

            try
                MCD = MClust.GetData();
                MCS = MClust.GetSettings();
            catch ERR
                disp(ERR.message);
                disp('Make sure to ResetMClust before proceeding.');
                delete(mainFigHandleToClose);
                return
            end
						
			if ~isempty(self.CC_displayWindow) && ishandle(self.CC_displayWindow)
                MCS.StoreWindowPlace(self.CC_displayWindow);% ADR 2013-12-12
				delete(self.CC_displayWindow);
			end
					
			figuresToClose = findobj('Tag', MCS.DeletableFigureTag);
			close(figuresToClose);
			
			delete(self);
			
			if ~isempty(mainFigHandleToClose) && ishandle(mainFigHandleToClose)...
					&& ~streq(get(mainFigHandleToClose, 'BeingDeleted'), 'on')
                MCS.StoreWindowPlace(mainFigHandleToClose); % ADR 2013-12-12
				delete(mainFigHandleToClose);
			end
			
		end
		
		%-----------------------------------------------------
		% import/export clusters
		%-----------------------------------------------------
		function importClusters(self)
			MCD = MClust.GetData();
			self.Clusters = MCD.Clusters;
		end
		
		function exportClusters(self, clusters)
			if nargin==1
				clusters = self.Clusters;
			end
			MCD = MClust.GetData();
			if self.append.AisON()
				MCD.Clusters = cat(2, MCD.Clusters, clusters);
			else
				MCD.Clusters = clusters;
			end
		end
		
		%-----------------------------------------------------
		% internal information gathering
		%-----------------------------------------------------
		function iD = get_xAxis(self)
			iD = get(self.xAxisLB, 'Value');
		end
		function iD = get_yAxis(self)
			iD = get(self.yAxisLB, 'Value');
		end
		
		function set_xAxis(self, iD)
			assert(iD>=1 && iD<=length(self.Features));
			set(self.xAxisLB, 'Value', iD);
		end
		function set_yAxis(self, iD)
			assert(iD>=1 && iD<=length(self.Features));
			set(self.yAxisLB, 'Value', iD);
		end
		
		function xFeat = get_xFeature(self)
			xFeat = self.Features{self.get_xAxis};
		end
		function yFeat = get_yFeature(self)
			yFeat = self.Features{self.get_yAxis};
		end
		
		function marker = get_plotMarker(self)
			s = get(self.axisMarkerSelect, 'String');
			v = get(self.axisMarkerSelect, 'Value');
			marker = s{v};
		end
		function size = get_plotMarkerSize(self)
			s = get(self.axisMarkerSize, 'String');
			v = get(self.axisMarkerSize, 'Value');
			size = str2double(s{v});
		end
		function bool = get_redrawStatus(self)
			bool = get(self.redrawAxesButton, 'Value');
		end
		function set_redrawStatus(self,B)
			set(self.redrawAxesButton, 'Value', B);
		end
		
		function C = getClusters(self)
			C = self.Clusters;
		end
		
		function N = getClusterNames(self)
			N = cellfun(@(iC,x)sprintf('%2d: %s', iC, x.name), num2cell(1:length(self.Clusters)), self.Clusters, 'UniformOutput', false);
		end
		
		function n = getFeatureNames(self)
			n = cellfun(@(x)x.name, self.Features, 'UniformOutput', false);
		end
		
		function iX = findSelf(self, C)
			% a cluster asks to find where it is in the cluster list
			iX = find(cellfun(@(x)isequal(C, x), self.Clusters));
		end
		
		function S = getUnaccountedForPoints(self)
            MCD = MClust.GetData();
            C = self.getClusters();
            S = 1:MCD.nSpikes;
            for iC = 2:length(C)
                S = setdiff(S, C{iC}.GetSpikes());
            end
		end
		
	end
	
	methods(Access=public)
		% ----------- redisplay
		function ReGo(self)
			self.RedrawAxes();
			self.RedrawClusters();
		end
		
		%-----------------------------------------------------
		function GetFocus(self)
			if ishandle(self.CC_figHandle) 
				figure(self.CC_figHandle);
			else
				self.CreateCutterWindow();
			end
		end
		
		%----------------------------------------------------
		% CALLBACKS
		%----------------------------------------------------
				
		function ExitCutter(self, export)
			if export 
				self.exportClusters();
			end
			self.close();			
		end
				
		%------------ AXES
		function StepForwards(self, ~, ~)
			nF = length(self.Features);
			x = self.get_xAxis; y = self.get_yAxis;
			y = y+1;
			if y>nF;  x=x+1; y = x; end
			if x>nF; x = 1; y=1; end
			self.set_xAxis(x); self.set_yAxis(y);
			self.RedrawAxes();
		end
		
		function StepBackwards(self, ~, ~)
			nF = length(self.Features);
			x = self.get_xAxis; y = self.get_yAxis;
			y = y-1;
			if y<1; x=x-1; y = x; end
			if x<1; x = nF; y = nF; end
			self.set_xAxis(x); self.set_yAxis(y);
			self.RedrawAxes();
		end
		
		function CycleYDimensions(self, ~, ~)
			y0 = self.get_yAxis;
			nF = length(self.Features);
			for y = y0:nF
				self.set_yAxis(y);
				self.RedrawAxes();
				pause(0.01);
			end
		end
		
		function CycleAllDimensions(self, ~, ~)
			x0 = self.get_xAxis; y0 = self.get_yAxis;
			nF = length(self.Features);
			for x = x0:nF
				for y = y0:nF
					self.set_xAxis(x);
					self.set_yAxis(y);
					self.RedrawAxes();
					pause(0.01);
				end
			end
		end
		
		%------------------- DISPLAY
		function FocusOnAxes(self)
			figure(self.CC_displayWindow);
		end
		
		%------------------- MARKERS
		function ChangeMarkers(self, ~, ~)
			MCS = MClust.GetSettings();
			C = self.getClusters();
			
			s = get(self.axisMarkerSelect, 'String');
			v = get(self.axisMarkerSelect, 'Value');
			marker = s{v};
			MCS.ClusterCutWindow_Marker = v;
			for iC = 1:length(C)
				C{iC}.marker = marker;
			end
			self.RedrawAxes();
		end
		
		function ChangeMarkerSizes(self, ~, ~)
			MCS = MClust.GetSettings();
			C = self.getClusters();
			
			s = get(self.axisMarkerSize, 'String');
			v = get(self.axisMarkerSize, 'Value');
			markerSize = str2double(s{v});
			MCS.ClusterCutWindow_MarkerSize = v;
			for iC = 1:length(C)
				C{iC}.markerSize = markerSize;
			end
			self.RedrawAxes();
		end
		
		function HideClusters(self, ~, ~)
			C = self.getClusters();
			for iC = 1:length(C)
				C{iC}.hide = true;
			end
			self.ReGo();
		end
		function ShowClusters(self, ~, ~)
			C = self.getClusters();
			for iC = 1:length(C)
				C{iC}.hide = false;
			end
			self.ReGo();
		end
		
		%-------------------------------
		% AVAILABLE FUNCS
		%-------------------------------
		function R = FindCutterFunctions(self)
			m = methods(self);
			cutterfuncs = strncmp(self.CutterFuncKey, m, length(self.CutterFuncKey));
			R = m(cutterfuncs)';
			for iR = 1:length(R)
				R{iR} = R{iR}((length(self.CutterFuncKey)+1):end);
			end
		end
		
		function CallCutterFunction(self, cfn, ~)
			if nargin==1 || cfn==0
				s = get(self.cutterFuncMenu, 'String');
				v = get(self.cutterFuncMenu, 'Value');
				cfn = s{v};
			end
			feval([self.CutterFuncKey cfn], self);
		end
		
		
	end
	
end

