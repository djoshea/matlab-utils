classdef ListboxPair
	% A pair of listboxes, when an entry is selected it is moved from one
	% box to the other.  (Typically used as a set of "available" and "use"
	% boxes.
	
	properties(Constant)
		leftTitlePosition  = [0.05 0.85 0.4 0.1];
		leftBoxPosition    = [0.05 0.05 0.4 0.80];
		rightTitlePosition = [0.55 0.85 0.4 0.1];
		rightBoxPosition   = [0.55 0.05 0.4 0.80];
	end

	properties(Access=public)

		parent;
				
		baseFrame;
		
		leftBox;	
		rightBox;
		
		secondaryCallback = [];
	end
	
	methods(Static)
		function transfer(fromLB, toLB)
			fromString = get(fromLB, 'String');
			if isempty(fromString), return; end
			valueFrom = get(fromLB, 'Value');
			toString = get(toLB, 'String');
			if isempty(toString)
				toString = fromString(valueFrom);
				set(toLB, 'Value', 1);
			else
				toString(end+1) = fromString(valueFrom);
				toString = sort(toString);
			end			
			fromString(valueFrom) = [];
			if isempty(fromString)
				fromString = '';
			end
			
			set(fromLB, 'String', fromString);
			set(toLB, 'String', toString);
			set(fromLB, 'Value', max(1, min(length(fromString), valueFrom)));
		end
						
	end
		
	methods
		
		% Transfer
		function LeftBoxClick(self, ~, ~)
			self.transfer(self.leftBox, self.rightBox);
			if ~isempty(self.secondaryCallback)
				self.secondaryCallback();
			end
		end
		function self = RightBoxClick(self, ~, ~)
			self.transfer(self.rightBox, self.leftBox);
			if ~isempty(self.secondaryCallback)
				self.secondaryCallback();
			end
		end
		
		% Write in
		function SetLeftList(self, L)
			set(self.leftBox, 'String', L);
		end
		function SetRightList(self, L)
			set(self.rightBox, 'String', L);
		end
		
		
		% Read out
		function L = GetLeftList(self)
			L = get(self.leftBox, 'String');
		end
		function L = GetRightList(self)
			L = get(self.rightBox, 'String');
		end
		
		% SetLists
		function self = SetLists(self, leftList, rightList)
			set(self.leftBox, 'String', leftList);
			set(self.rightBox, 'String', rightList);
		end
		
		% Constructor
		function self = ListboxPair(parent, position, leftTitle, rightTitle, varargin)									
			
			self.parent = parent;
			
			secondaryCallback = []; %#ok<PROP>
			leftToolTip = ''; rightToolTip = ''; 
			leftList = {}; rightList = {};
			process_varargin(varargin);
			self.secondaryCallback = secondaryCallback; %#ok<PROP>
			
			self.baseFrame = uipanel('Parent', self.parent, 'Position', position);
							
			uicontrol('Parent', self.baseFrame, 'Style', 'text', ...
				'String', leftTitle, ...
				'Units', 'Normalized', 'Position', self.leftTitlePosition);
			uicontrol('Parent', self.baseFrame, 'Style', 'text', ...
				'String', rightTitle, ...
				'Units', 'Normalized', 'Position', self.rightTitlePosition);

		self.leftBox =  uicontrol('Parent', self.baseFrame,...
			'Units', 'Normalized', 'Position', self.leftBoxPosition,...
			'Style', 'listbox', 'Tag', 'leftList', ...
			'HorizontalAlignment', 'left', ...
			'Enable','on', 'String', leftList, ...
			'TooltipString', leftToolTip);
		self.rightBox =  uicontrol('Parent', self.baseFrame,...
			'Units', 'Normalized', 'Position', self.rightBoxPosition,...
			'Style', 'listbox', 'Tag', 'rightList',...
			'HorizontalAlignment', 'left', ...
			'Enable','on', 'String', rightList,...
			'TooltipString', rightToolTip);
		set(self.leftBox, 'Callback', @(src,event)LeftBoxClick(self,src,event));
		set(self.rightBox, 'Callback', @(src,event)RightBoxClick(self,src,event));

		end
	end
end
