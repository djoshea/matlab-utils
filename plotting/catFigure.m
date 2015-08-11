function catFigure(figh)

    if nargin == 0
        figh = gcf;
    end

    % save the figure
    fname = [tempname '.png'];
    saveFigure(fname, figh);
    imgcat(fname);

end
