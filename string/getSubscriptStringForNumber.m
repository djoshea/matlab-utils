function out = getSubscriptStringForNumber(values)
    out = arrayfun(@getSingleString, values);
end

function str = getSingleString(val)
    char_num = char(num2str(val));
    subs = ["₀", "₁", "₂", "₃", "₄", "₅", "₆", "₇", "₈", "₉"];
    dot = ".";

    str = "";
    for iV = 1:numel(char_num)
        if char_num(iV) == '.'
            this = dot;
        else
            this = subs(str2double(char_num(iV))+1);
        end
        str = str + this;
    end
end
