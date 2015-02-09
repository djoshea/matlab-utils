function color = htmlColor(str)

    if str(1) == '#'
        str = str(2:end);
    end

    if numel(str) == 3
        str = ['0' str(1) '0' str(2) '0' str(3)];
    end

    assert(numel(str) == 6, 'String must have 3 or 6 digit hex color code');

    r = hex2dec(str(1:2));
    g = hex2dec(str(3:4));
    b = hex2dec(str(5:6));

    color = [r g b] / 255;
end
