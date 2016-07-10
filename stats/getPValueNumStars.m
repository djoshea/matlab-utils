function [numStars, text] = getPValueNumStars(p)

    numStars = arrayfun(@getNum, p);
    
    text = arrayfun(@(n) repmat('*', 1, n), numStars, 'UniformOutput', false);
    
    for iT = 1:numel(text)
        if isempty(text{iT})
            text{iT} = '';
        end
    end
    
    if isscalar(p)
        text = text{1};
    end 
    
    function n = getNum(p)
        if p < 0.0001
            n = 4;
        elseif p < 0.001
            n = 3;
        elseif p < 0.01
            n = 2;
        elseif p < 0.05 
            n = 1;
        else
            n = 0;
        end
    end
end
