function hcprintfDemo

[R,C] = getTerminalSize();
R = R-2;
bgs = flipud(cubehelix(R*C));
fgs = repmat(cubehelix(C), R, 1);

pieces = cell(R, C);
for i = 1:numel(pieces)
    bg = bgs(i, :);
    fg = fgs(i, :);
    pieces{i} = sprintf('{%.4f,%.4f,%.4f;%.4f,%.4f,%.4f}@', fg, bg);
    if mod(i, C) == 0
        pieces{i} = [pieces{i} '\n'];
    end
end

str = cat(2, pieces{:});
hcprintf(str);