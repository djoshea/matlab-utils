classdef AnchorInfo < handle
    properties
        desc = ''; % description for debugging purposes
        
        processed = false; % logical indicating whether it has already been processed this round
        valid = true;
        
        h % handle or vector of handles of object(s) to position
        ha % handle or vector of handles of object(s) to serve as anchor
        
        pos % AutoAxisPositionType value for this object
        posa % AutoAxisPositionType value or numerical scalar in paper units
        
        margin % gap between h point and anchor point in paper units
        
        %data % scalar value indicating the data coordinate used when posAnchro is Data
    end  
    
    methods
        function ai = AnchorInfo(varargin)
            p = inputParser;
            p.addOptional('h', [], @(x) isvector(x) || isempty(x)); % this may be a vector
            p.addOptional('pos', [], @(x) isempty(x) || isa(x, 'AutoAxis.PositionType'));
            p.addOptional('ha', [], @(x) isvector(x) || isempty(x));
            p.addOptional('posa', [], @(x) isempty(x) || isa(x, 'AutoAxis.PositionType') || isscalar(x));
            p.addOptional('margin', 0, @(x) isscalar(x));
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

    
    
