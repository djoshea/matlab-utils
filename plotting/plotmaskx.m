function plotmaskx(varargin)
% plotmaskx(mask, [y]) or plotmaskx(x, mask, [y])

    if islogical(varargin{1})
        tf = varargin{1};
        x = 1:numel(tf);
        args = varargin(2:end);
    elseif islogical(varargin{2})
        x = varargin{1};
        tf = varargin{2};
        args = varargin(3:end);
    else
        error('First or second arg must be logical');
    end

    if ~isempty(args) && isscalar(args{1})
        y = args{1};
        args = args(2:end);
    else
        yl = ylim();
        y = yl(2);
    end

    yv = nan(size(x));
    yv(tf) = y;

    plot(x, yv, 'k-', 'LineWidth', 5, args{:});

end


    