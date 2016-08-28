function assignAllInBase()
    
    vars = evalin('caller', 'whos');

    for iV = 1:numel(vars)
        val = evalin('caller', vars(iV).name);
        assignin('base', vars(iV).name, val);
    end

end