classdef NRadioSwitch < handle
	
	properties
		buttongroup; % group for set
		buttonElements; % individual buttons
	end
	
	methods
		function self = NRadioSwitch(buttonNames, varargin)
			nButtons = length(buttonNames);
			self.buttongroup = feval(@uibuttongroup, varargin{:});
			set(self.buttongroup, 'Units', 'Normalized');
            for iB = 1:nButtons
                self.buttonElements{iB} = ...
                    uicontrol('String', buttonNames{iB}, ...
                    'Style', 'RadioButton', ...
                    'Units', 'Normalized', ...
                    'Position', [0 (iB-1)/nButtons 1 1/nButtons], ...
                    'Parent', self.buttongroup, 'UserData', iB);
            end
        end
		
		function delete(self)
			if ishandle(self.buttongroup)
				delete(self.buttongroup);
			end
		end
		
		function s = SelectionString(self)
			obj = get(self.buttongroup, 'SelectedObject');
			s = get(obj, 'string');
		end
		function SetI(self, iB)
			set(self.buttongroup, 'SelectedObject', self.buttonElements{iB});
		end

		function iB = GetI(self)
			iB = get(get(self.buttongroup, 'SelectedObject'), 'UserData');
		end
		
	end

			
end