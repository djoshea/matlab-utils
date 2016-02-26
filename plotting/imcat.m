function imcat(m, C)
    m = squeeze(double(m));
    
    % make large enough to see (min dimension should be 500 px)
    maxPixelSize = 10;
    [r, c] = size(m);
    
    if ~ismatrix(m)
        warning('Showing slice (:, :, 1) of multidimensional matrix');
        m = m(:, :, 1);
    end
    
    resizeBy = min(maxPixelSize, round(min(800 / r, 800 / c)));
    if resizeBy > 1
        m = kron(m, ones(resizeBy));
    end
    
    if nargin < 2
        % Now make an RGB image that matches display from IMAGESC:
        C = get(0, 'DefaultFigureColormap');  % Get the figure's colormap.
    end
    L = size(C,1);
    
    % Scale the matrix to the range of the map.
    maxM = nanmax(m(:));
    minM = nanmin(m(:));
    if ~isnan(maxM) && ~isnan(minM)
        if maxM - minM <= 2*eps
            mc = ones(size(m));
        else
            mc = round(interp1(linspace(minM,maxM,L),1:L,m));
        end
    else
        mc = m;
    end
    mc(isnan(mc)) = L+1; % specify nan's index into colormap
    C = cat(1, C, [0 0 0]); % make white the nan color
    mc = reshape(C(mc,:),[size(mc) 3]); % Make RGB image from scaled.
    
    f = tempname;
    imwrite(mc, f, 'png');
    imgcat(f);
end
    