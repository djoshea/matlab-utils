function catfig(figh)
    if nargin < 1
        figh = gcf;
    end
    fname = tempname();
    saveFigure(figh, fname, {'png'}, 'quiet', true);
    %print(figh, '-dpng', '-r100', sprintf('%s.png', fname));

    x = sprintf('export LD_LIBRARY_PATH=""; export DYLD_LIBRARY_PATH=""; /usr/local/bin/python %s/catimg %s.png', pathToThisFile(), fname);
    unix(x);
end
