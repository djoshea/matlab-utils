classdef tsd < ts
    % tsd object
    %
    % Rebuilt ADR 2011/12
    % contains:
    %        D - an n x M x ... data array matching
    %        T - a n x 1 sorted list of timestamps
    %
    % tsd objects are a subclass of ts, so they access all of the ts
    % objects methods
    
    properties
        D = [];
    end
    
    methods (Access = protected)
        function ok = tsdOK(tsa)
            ok = tsa.tsOK();
            ok = ok && (size(tsa.D,1) == size(tsa.T,1));
        end
    end
    
    methods
        
        % constructor
        function tsa = tsd(A,B)
            %  tsd(t,d) or tsd(tsd) or tsd(ctsd) - constructor			
            if nargin == 2
				if isa(A, 'ts') 
					t = A.range();
				else
					t = A;
				end
                d = B;
            elseif nargin==1 && (isa(A, 'tsd') || isa(A, 'ctsd'))
                t = A.range();
                d = A.data();
			elseif nargin==1 && isa(A, 'struct') && isfield(A, 't') && isfield(A, 'data')
				t = A.t;
				d = A.data;
			end
            
			if size(t,1) == 1, t=t'; end % Fixed.  This was a typo ADR 2012-03-27
            assert(size(d,1) == size(t,1), 'tsd constructor: first dimension of d must match t');
            tsa@ts(t);
            tsa.D = d;
            assert(tsa.OK(), 'tsd not OK');
        end
        
        % OK
        function ok = OK(tsa)
            %  OK() - is the list n x 1, in order, and does D match T
            ok = tsdOK(tsa);
        end
        
        function bool = eq(A, B)
            % A==B
            t = B.range(); d = B.data();
            bool = (length(A.T) == length(t)) && ...
                (all(size(A.D) == size(d))) && ...
                all(A.T == t) && ...
                all(isequalwithequalnans(A.D(:), d(:)));
		end
	end
end
