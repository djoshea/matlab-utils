classdef AnchorInfo < handle & matlab.mixin.Copyable
    properties
        desc = ''; % description for debugging purposes
        
        valid = true;
        
        h % handle or vector of handles of object(s) to position
        ha % handle or vector of handles of object(s) to serve as anchor
        
        pos % AutoAxisPositionType value for this object
        posa % AutoAxisPositionType value or numerical scalar in paper units
        
        margin % gap between h point and anchor point in paper units, can be string if expression
        
        %data % scalar value indicating the data coordinate used when posAnchro is Data
    end  
    
    properties(Hidden, SetAccess=?AutoAxis)
        % boolean flag for internal use. when pos is Height or Width,
        % indicates what should be fixed when scaling the height or width
        % e.g. if posScaleFixed is Top, the height should be changed by
        % moving the bottom down, keeping the Top fixed
        posScaleFixed
    end
    
    methods
        function ai = AnchorInfo(varargin)
            p = inputParser;
            validatePos = @(x) isempty(x) || isa(x, 'AutoAxis.PositionType') || isscalar(x) || ischar(x) || isa(x, 'function_handle');
            p.addOptional('h', [], @(x) isvector(x) || isempty(x)); % this may be a vector
            p.addOptional('pos', [], validatePos);
            p.addOptional('ha', [], @(x) isvector(x) || isempty(x));
            p.addOptional('posa', [], validatePos);
            p.addOptional('margin', 0, @(x) ischar(x) || isscalar(x) || isa(x, 'function_handle'));
            p.addOptional('desc', '', @ischar);
            
            p.parse(varargin{:});
            ai.h = p.Results.h;
            ai.pos = p.Results.pos;
            ai.ha = p.Results.ha;
            ai.posa = p.Results.posa;
            ai.margin = p.Results.margin;
            ai.desc = p.Results.desc;
        end
    end
end

    
    
