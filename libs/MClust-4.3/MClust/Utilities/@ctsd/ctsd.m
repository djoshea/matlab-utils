classdef ctsd
    % ctsd object
    %
    % Rebuilt ADR 2011/12
    % contains:
    %    T0 - starting time
    %    dt - timestep
    %    D - data: n x .. array of data
    %
    % ctsd objects assume that
    % -> T is sorted in ascending order
    % -> dt is stored in seconds
    % -> D is in order and complete
    %
    % ctsd should have the same exact functionality as tsd
    %
    % ctsd objects no longer accomodate units
    % if you absolutely need units, create a subclass
    
    properties
        T0 = [];
        dT = [];
        D = [];
    end
    
    methods (Access=protected)
        function n = nD(tsa)
            n = size(tsa.D,1);
        end
        
        function ok = ctsdOK(tsa)
            ok = max(size(tsa.T0))==1 && max(size(tsa.dT))==1;
        end
    end
    
    methods
        function tsa = ctsd(t0_, dt_, d_)
            % ctsd(tsd) or ctsd(ctsd) or ctsd(t0, dt, d)
            if nargin==3    %  ctsd(t0, dt, d)
                tsa.T0 = t0_;
                tsa.dT = dt_;
                tsa.D = d_;
            elseif nargin==1 && isa(t0_, 'tsd') 
				assert(all(diff(range(t0_))>0),  'input timestamps not in order');
                tsa.T0 = starttime(t0_);
                tsa.dT = dt(t0_);
                tsa.D = interp1(range(t0_), data(t0_), ...
                    (starttime(t0_):dt(t0_):endtime(t0_))', ...
                    'linear', 'extrap'); % fixed for Matlab 2012
			elseif nargin==1 && isa(t0_, 'ctsd')
                tsa.T0 = starttime(t0_);
                tsa.dT = dt(t0_);
                tsa.D = interp1(range(t0_), data(t0_), ...
                    (starttime(t0_):dt(t0_):endtime(t0_))', ...
                    'linear', 'extrap'); % fixed for Matlab 2012
            end
            assert(tsa.ctsdOK(), 'ctsd not OK');
        end
        
        function ok = OK(tsa)
            % ok - T0 and dT should be 1x1
            ok = tsa.ctsdOK();
        end
        
        function t0 = starttime(tsa)
            % starttime() - first element
            t0 = tsa.T0;
        end
        
        function t1 = endtime(tsa)
            % endtime() - last element
            t1 = tsa.T0 + tsa.dT*(tsa.nD()-1);
        end
        
        function d = range(tsa)
            % range() - t
            d = tsa.T0 + tsa.dT * ((1:tsa.nD())-1)';
        end
        
        function y = dt(tsa)
            % dt() - timestep
            y = tsa.dT;
        end
        
        function bool = eq(A, B)
            % A==B
            if isa(B, 'ctsd')
                bool = (A.T0 == B.T0) && ...
                    (A.dT == B.dT) && ...
                    (all(size(A.D) == size(B.D))) && ...
                    all(isequalwithequalnans(A.D(:), B.D(:)));
            elseif isa(B, 'tsd')
                t = B.range(); d = B.data();
                bool = (length(t) == A.nD()) && ...
                    (all(t == A.range())) && ...
                    (all(size(d) == size(A.D))) && ...
                    (all(isequalwithequalnans(d(:), A.D(:))));
            end
        end
       
        % units
        function units(tsa) %#ok<MANU>
            error('ts:Units', 'ts objects no longer support units. ts objects should store all data in seconds.');
        end
        
        
    end
    
end

