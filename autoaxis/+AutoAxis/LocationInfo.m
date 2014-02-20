classdef LocationInfo < handle
   
    properties(Dependent)
        top
        bottom
        vcenter
        height
        
        left
        right
        hcenter
        width
    end

    properties(Access=protected)
        vtop = NaN;
        vbottom = NaN;
        vvcenter = NaN;
        vheight = NaN;
        
        vleft = NaN;
        vright = NaN;
        vhcenter = NaN;
        vwidth = NaN;
    end

    methods
        function [t, b, vc, h] = computeY(loc)
            [t, b, vc, h] = loc.solveSys(loc.vtop, loc.vbottom, ...
                loc.vvcenter, loc.vheight);
        end
        
        function [r, l, hc, w] = computeX(loc)
            [r, l, hc, w] = loc.solveSys(loc.vright, loc.vleft, ...
                loc.vhcenter, loc.vwidth);
        end
        
        function [hi, lo, mid, r] = solveSys(loc, hi, lo, mid, r)
            % where vars = [top; bottom; center; height] or
            % [left; right; center; width], solves for uknown quantities
            % (NaNs) and returns the complete vector
            
            if isempty(hi), hi = NaN; end
            if isempty(lo), lo = NaN; end
            if isempty(mid), mid = NaN; end
            if isempty(r), r = NaN; end
            
            vars = [hi;lo;mid;r];
            known = ~isnan(vars);
            
            if nnz(known) < 2
                % can't do any better
                return;
            elseif nnz(known) > 2
                error('Overconstrained position spec');
            end
            
            % solve for the unknown values
            constraints = ...
                [  0  -1   1 -1/2; ...
                   1   0  -1 -1/2; ...
                   1  -1   0   -1; ...
                   1   1  -2    0 ];   
            off = constraints(:, known) * vars(known);
            valsUnknown = constraints(:, ~known) \ (-off);
            vars(~known) = valsUnknown;
            
            hi = vars(1);
            lo = vars(2);
            mid = vars(3);
            r = vars(4);
        end 
        
%         function updateVals(loc, which, val)
%            % store a new value in place of the old value, but reset the value
%            % of any associated variables if it would overconstrain the
%            % position specification
%            
%            % update the value
%            loc.(['v' which]) = val;
%            
%            [tf, idx] = ismember(which, {'top', 'bottom', 'vcenter', 'height'});
%            if tf
%                yVals = [loc.vtop, loc.vbottom, loc.vvcenter, loc.vheight];
%                
%                % figure out which specifications to keep
%                ySpec = find(~isnan(yVals));
%                ySpec = setdiff(ySpec, idx);
%                if numel(ySpec) > 1
%                    % and nullify over-constraining elements
%                    yVals(ySpec(2:end)) = NaN;
%                end
%                
%                loc.vtop = yVals(1);
%                loc.vbottom = yVals(2);
%                loc.vvcenter = yVals(3);
%                loc.vheight = yVals(4);
%            end
%              
%         end
    end
    
    methods
        function t = get.top(loc)
            t = loc.computeY();
        end

        function set.top(loc, v)
            loc.vtop = v;
        end

        function v = get.bottom(loc)
           [~, v] = loc.computeY();
        end

        function set.bottom(loc, v)
            loc.vbottom = v;
        end
        
        function v = get.vcenter(loc)
            [~, ~, v] = loc.computeY();
        end
        
        function set.vcenter(loc, v)
            loc.vvcenter = v;
        end

        function v = get.height(loc)
            [~, ~, ~, v] = loc.computeY();
        end

        function set.height(loc, v)
            loc.vheight = v;
        end

        function v = get.left(loc)
            [~, v] = loc.computeX();
        end

        function set.left(loc, v)
            loc.vleft = v;
        end

        function v = get.right(loc)
            v = loc.computeX();
        end

        function set.right(loc, v)
            loc.vright = v;
        end
        
        function v = get.hcenter(loc)
            [~, ~, v] = loc.computeX();
        end
        
        function set.hcenter(loc, v)
            loc.vhcenter = v;
        end

        function v = get.width(loc)
            [~, ~, ~, v] = loc.computeX();
        end

        function set.width(loc, v)
            loc.vwidth = v;
        end
    end

end
