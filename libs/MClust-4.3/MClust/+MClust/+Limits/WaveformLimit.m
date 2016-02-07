classdef  WaveformLimit < handle
    % WaveformLimit class 
    
    properties
        channel = [];
        sample = [];
        min = [];
        max = [];
    end
    
    methods
        function self = WaveformLimit(channel, sample, min, max)
            self.channel = channel;
            self.sample = sample;
            self.min = min;
            self.max = max;
        end
        
      
        function [S, keep] = ApplyLimit(self, WV, S)
            if ~isempty(self.channel)
                WVD = WV.data;
                [~, nCh, nSamp] = size(WVD);
                assert(nCh >= self.channel); 
                assert(nSamp >= self.sample);
                keep = (WVD(:,self.channel,self.sample) >= self.min) & (WVD(:,self.channel,self.sample) <= self.max);
                S = S(keep);
            end
        end 
    end % methods    
end % class

