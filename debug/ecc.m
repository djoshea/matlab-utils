function ecc(obj)
    if ischar(obj)
        % called as "ec obj", get class of obj in the base workspace
        c = evalin('caller', sprintf('class(%s)', obj));
        code(c);
    else
        code(class(obj));
    end
end