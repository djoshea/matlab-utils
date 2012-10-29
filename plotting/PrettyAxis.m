classdef PrettyAxis < handle

    properties
        groups
    end

    methods
        function ax = PrettyAxis(ax, varargin)
            
        end

        function addGroup(ax, varargin)
            if nargin < 1
                error('Usage: addGroup(PrettyAxisGroup) or addGroup(''ticks'', etc.');
            end
            if ~isa(varargin{1}, 'PrettyAxisGroup')
                group = PrettyAxisGroup(varargin{:});
            end
            groups(end+1) = group; 
        end

        function drawOnAxis(ax, axh)
            for i = 1:ax.nGroups
                
            end
        end
    end

end
