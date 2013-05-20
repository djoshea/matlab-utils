function cmap = interpColormap(cmapIn, N)

xIn = 0:(size(cmapIn, 1)-1);
xOut = linspace(0, xIn(end), N);
cmap = interp1(xIn, cmapIn, xOut);

end