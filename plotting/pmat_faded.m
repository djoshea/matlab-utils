function h = pmat_faded(vals, varargin)
    p = inputParser();
    p.addParameter('y', 1:size(vals, 1));
    p.addParameter('x', 1:size(vals, 2));
    p.addParameter('fade_window', [0 0 0 0], @isvector); % left bottom right top, in scale of x + y
    p.addParameter('useAlpha', true, @islogical); % if true, uses AlphaData to do fading, if false, blends with white.
    p.addParameter('background', [], @isvector);
    p.addParameter('colormap', []);
    p.addParameter('clim', []);
    p.KeepUnmatched = true;
    p.parse(varargin{:});

    fade_window = p.Results.fade_window;
    if isscalar(fade_window)
        fade_window = repmat(fade_window, 1, 4);
    elseif numel(fade_window) == 2
        fade_window = repmat(makerow(fade_window), 1, 2);
    else
        assert(numel(fade_window) == 4);
    end


    y = p.Results.y;
    x = p.Results.x;
    dy = abs(median(diff(y)));
    dx = abs(median(diff(x)));
    fade_samples = floor([fade_window(1) / dx, fade_window(2) / dy, fade_window(3) / dx, fade_window(4) / dy]);

    [Y, X] = size(vals, [1 2]);
    ramp = @(n) linspace(0, 1, n);
    revramp = @(n) linspace(1, 0, n);

    % we add 1 to both middles because of the extra right / bottom edge added
    middle = Y - (fade_samples(2) + fade_samples(4));
    assert(middle > 0, "Matrix not tall enough for vertical fade");
    fade_y = [ramp(fade_samples(2))'; ones(middle, 1); revramp(fade_samples(4))'];

    middle = X - (fade_samples(1) + fade_samples(3));
    assert(middle > 0, "Matrix not wide enough for horizontal fade");
    fade_x = [ramp(fade_samples(1)), ones(1, middle), revramp(fade_samples(3))];

    alpha_data = min(fade_x, fade_y);

    if p.Results.useAlpha
        h = pmat(vals, p.Unmatched, x=x, y=y);
        set(h, AlphaDataMapping="none", AlphaData=alpha_data, FaceAlpha="flat");
    else
        % actually blend with white
        cmap = p.Results.colormap;
        if isempty(cmap)
            cmap = TrialDataUtilities.Colormaps.mako();
        end

        clim = p.Results.clim;
        if isempty(clim)
            clim = [min(vals(:), [], 'omitnan'), max(vals(:), [], 'omitnan')];
        end
        background = p.Results.background;
        if isempty(background)
            background = [1 1 1];
        end

        mask_nan = isnan(vals);
        vals(mask_nan) = clim(1);
        alpha_data(mask_nan) = 0;
        img = TrialDataUtilities.Color.evalColorMapAt(cmap, vals, clim);
        
        faded_img = img .* alpha_data + reshape(background, [1 1 3]) .* (1-alpha_data);
        h = pimg(faded_img, p.Unmatched, x=x, y=y);
    end
end

% test:
% pmat_faded(randn(100, 100), fade_window = 25)