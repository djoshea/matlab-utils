classdef TwoRadioSwitch < handle
	
	properties
		buttongroup;
		buttonA;
		buttonB;		
	end
	
	methods
		function self = TwoRadioSwitch(varargin)
			AName = 'A'; BName = 'B';
			varargin = process_varargin(varargin);
			self.buttongroup = feval(@uibuttongroup, varargin{:});
			set(self.buttongroup, 'Units', 'Normalized');
			self.buttonA = uicontrol('String', AName, ...
				'Style', 'RadioButton', ...
				'Units', 'Normalized', ...
				'Position', [0   0 0.5 1], ...
				'Parent', self.buttongroup);
			self.buttonB = uicontrol('String', BName, ...
				'Style', 'RadioButton', ...
				'Units', 'Normalized', ...
				'Position', [0.5 0 0.5 1], ...
				'Parent', self.buttongroup);			
			self.enable();
		end
		
		function delete(self)
			if ishandle(self.buttongroup)
				delete(self.buttongroup);
			end
		end
		
		function disable(self)
			set(self.buttonA, 'enable', 'off');
			set(self.buttonB, 'enable', 'off');
		end
		
		function enable(self)
			set(self.buttonA, 'enable', 'on');
			set(self.buttonB, 'enable', 'on');
		end
		
		function s = SelectionString(self)
			obj = get(self.buttongroup, 'SelectedObject');
			s = get(obj, 'string');
		end
		function SetA(self)
			set(self.buttongroup, 'SelectedObject', self.buttonA);
		end
		function SetB(self)
			set(self.buttongroup, 'SelectedObject', self.buttonB);
		end
		
		function bool = AisON(self)
			bool = get(self.buttonA, 'value');
		end

		function bool = BisON(self)
			bool = get(self.buttonA, 'value');
		end
		
	end

			
end