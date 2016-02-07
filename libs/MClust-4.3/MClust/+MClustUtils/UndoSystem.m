classdef UndoSystem < handle
    % UndoSystem
    %   stores a set of undos, each labeled by a name
	%
	% ADR 2013-03-19 Does a copy of copyable handle classes.  Copies into
	% one-step of a cell array of copyable classes.
    
    properties (Access = public)
        maxUndo = 10;
        Undo = {}; UndoNames = {};
    end
    
    methods
        function self = UndoSystem(n)
            if nargin==0
                n = self.maxUndo;
            end
            self.maxUndo = n;
            self.Undo = {};
			self.UndoNames = {};
        end
        
        function StoreUndo(self, X, name)
            % stores X in the UndoStack
			if iscell(X)
				if any(cellfun(@(x)isa(x, 'matlab.mixin.Copyable'), X)) % need to deepcopy
					self.Undo{end+1} = cellfun(@(x)copy(x), X, 'UniformOutput', false);
				else
					self.Undo{end+1} = X; % can't copy them, just take the cell array
				end
			elseif ishandle(X) 
				self.Undo{end+1} = copy(X); % need to copy this
			else
				self.Undo{end+1} = X; % just take it
			end
			self.UndoNames{end+1} = name;
			if length(self.Undo) > self.maxUndo
				self.Undo(1) = [];
				self.UndoNames(1) = [];
			end
		end
               
        function X = PopUndo(self)
            if self.anythingToUndo
                % recalls X from the undo stack
                X = self.Undo{end};
                self.Undo(end) = []; self.UndoNames(end) = [];
            else
                X = {};
            end
        end
        
        function b = anythingToUndo(self)
            b = ~isempty(self.Undo);
        end
        
        function nm = nextUndoName(self)
            if ~isempty(self.UndoNames)
                nm = self.UndoNames{end};
            else
                nm = '';
            end
        end
    end
    
end

