function html = rgb2html(rgb, includePound)
    if nargin < 2
        includePound = false;
    end
    
    to_hex = @(f) dec2hex(round(f*255), 2);

    N = size(rgb, 1);
    assert(size(rgb, 2) == 3);
    
    html = strings(N, 1);
    for i = 1:N
        r = to_hex(rgb(i, 1));
        g = to_hex(rgb(i, 2));
        b = to_hex(rgb(i, 3));

        if includePound
            html(i) = "#" + string(r) + string(g) + string(b);
        else
            html(i) = string(r) + string(g) + string(b);
        end
    end
end
