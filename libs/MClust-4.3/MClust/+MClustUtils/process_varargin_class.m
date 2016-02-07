function leftoverV = process_varargin_class(self, varargin)

% leftoverV = process_varargin(self, varargin)
%
%  INPUTS
%     V - varargin cell array
%
%  OUTPUTS
%     leftoverV - varargins not processed
%
%   expects varargin to consist of sequences of 'variable', value
%   sets variable to value for each pair.
%   changes the current workspace!
%
%   Now only processes variables that already exist in the parent workspace
%
%
% ADR 2011

leftoverV = {};
P = properties(self);
for iV = 1:2:length(varargin)
	if ismember(varargin{iV}, P)
		self.(varargin{iV}) = varargin{iV+1};
	else
		leftoverV = cat(1, leftoverV, varargin(iV), varargin(iV+1));
	end
end

end % process_varargin
