function hcprintfDemo

[R,C] = getTerminalSize();
colors = cubehelix(R*C);

pieces = cell(R, C);
for i = 1:numel(pieces)
    color = colors(i, :);
    pieces{i} = sprintf('{;%.4f,%.4f,%.4f} ', color);
    if mod(i, C) == 0
        pieces{i} = [pieces{i} '\n'];
    end
end

str = cat(2, pieces{:});
hcprintf(str);