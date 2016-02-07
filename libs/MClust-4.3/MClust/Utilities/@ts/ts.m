classdef ts
	% ts object
	% 
	% Rebuilt ADR 2011/12
	% contains: T - a n x 1 sorted list of timestamps
	%
	% ts objects assume that 
	% -> T is stored in seconds
	% ------> ts objects do NOT assume T is sorted in ascending order
	%
	% ts objects no longer accomodate units
	% if you absolutely need units, create a subclass
	
	properties 
		T = [];
    end
	
    methods (Access = protected)
        function ok = tsOK(tsa)
            ok = isempty(tsa.T) || (size(tsa.T,2)==1);
			% ok = ok && all(diff(tsa.T)>0);  REMOVED - NO LONGER ASSUMES
        end
    end
    
	methods			
		
		% constructor
		function tsa = ts(t)
			%  ts(t) - constructor
			if size(t,1) == 1, t=t'; end
			tsa.T = t;
            assert(tsa.tsOK(), 'ts component not OK');
		end
				
		% OK
		function ok = OK(tsa)
			%  OK() - is the list n x 1 and in order?
            ok = tsa.tsOK();
		end
		
		% starttime
		function t0 = starttime(tsa)
			% starttime() - first element
			if isempty(tsa.T)
				t0 = nan;
			else
				t0 = tsa.T(1);
			end
		end
		
		% endtime
		function t1 = endtime(tsa)
			% endtime() - last element
			if isempty(tsa.T)
				t1 = nan;
			else
				t1 = tsa.T(end);
			end
		end
				
		% range
		function d = range(tsa)
			% range() - t
			d = tsa.T;
		end		
		
		% dt
		function y = dt(tsa)
			% dt() - median of the differences
			y = nanmedian(diff(tsa.T));
        end
        
        function bool = eq(A, B)
            % A==B
            t = B.range();
            bool = (length(A.T) == length(t)) && all(A.T == t);
        end

		        
		% units
		function units(tsa) %#ok<MANU>
			error('ts:Units', 'ts objects no longer support units. ts objects should store all data in seconds.');
		end
			
	end
		
	
end