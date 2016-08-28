function ec(obj)
    if ischar(obj)
        % called as "ec obj", get class of obj in the base workspace
        c = evalin('caller', sprintf('class(%s)', obj));
        edit(c);
    else
        edit(class(obj));
    end
end