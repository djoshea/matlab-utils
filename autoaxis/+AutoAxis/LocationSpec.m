classdef LocationSpec < handle & matlab.mixin.Copyable
   
     % Specifed properties inferred from properties beginning with v*
     % or false if not specified
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

    % Manually specified values which inform and are set by the properties above
    properties(SetAccess=protected) 
        stop = false;
        sbottom = false;
        svcenter = false;
        sheight = false;
        
        sleft = false;
        sright = false;
        shcenter = false;
        swidth = false;
    end
    
    methods
        function flush(spec)
            spec.stop = false;
            spec.sbottom = false;
            spec.svcenter = false;
            spec.sheight = false;

            spec.sleft = false;
            spec.sright = false;
            spec.shcenter = false;
            spec.swidth = false;
        end
        
        function [t, b, vc, h] = computeY(spec)
            [t, b, vc, h] = spec.solveSys(spec.stop, spec.sbottom, ...
                spec.svcenter, spec.sheight);
        end
        
        function [r, l, hc, w] = computeX(spec)
            [r, l, hc, w] = spec.solveSys(spec.sright, spec.sleft, ...
                spec.shcenter, spec.swidth);
        end
        
        function [hi, lo, mid, r] = solveSys(spec, hi, lo, mid, r)
            % where vars = [top; bottom; center; height] indicates which
            % ones are specified, the returned values indicates whether 
            % the other variables are implicitly specified as well
            
            vars = [hi;lo;mid;r];
            known = nnz(vars);
            
            if nnz(known) >= 2
                % we could derive the other positions from this
                hi = true;
                lo = true;
                mid = true;
                r = true;
            end
        end 
    end
    
    methods
        function t = get.top(spec)
            t = spec.computeY();
        end

        function set.top(spec, v)
            spec.stop = v;
        end

        function v = get.bottom(spec)
           [~, v] = spec.computeY();
        end

        function set.bottom(spec, v)
            spec.sbottom = v;
        end
        
        function v = get.vcenter(spec)
            [~, ~, v] = spec.computeY();
        end
        
        function set.vcenter(spec, v)
            spec.svcenter = v;
        end

        function v = get.height(spec)
            [~, ~, ~, v] = spec.computeY();
        end

        function set.height(spec, v)
            spec.sheight = v;
        end

        function v = get.left(spec)
            [~, v] = spec.computeX();
        end

        function set.left(spec, v)
            spec.sleft = v;
        end

        function v = get.right(spec)
            v = spec.computeX();
        end

        function set.right(spec, v)
            spec.sright = v;
        end
        
        function v = get.hcenter(spec)
            [~, ~, v] = spec.computeX();
        end
        
        function set.hcenter(spec, v)
            spec.shcenter = v;
        end

        function v = get.width(spec)
            [~, ~, ~, v] = spec.computeX();
        end

        function set.width(spec, v)
            spec.swidth = v;
        end
    end

end
