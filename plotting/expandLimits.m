function [xl, yl] = expandLimits(xl, yl, varargin)
% expand limits to span the limits of all axes passed in

for i = 1:numel(nargin)
    arg = varargin{i};
    for j = 1:numel(arg)
        xln = xlim(arg(j));
        yln = ylim(arg(j));

        if isempty(xl)
            xl = xln;
        else
            xl(1) = min(xl(1), xln(1));
            xl(2) = max(xl(2), xln(2));
        end
        if isempty(yl)
            yl = yln;
        else
            yl(1) = min(yl(1), yln(1));
            yl(2) = max(yl(2), yln(2));
        end
    end
end
