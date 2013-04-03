function s = getPValueNumStars(p)

    s = arrayfun(@getNum, p);
    
    function n = getNum(p)
        if p < 0.0001
            n = 4;
        elseif p < 0.001
            n = 3;
        elseif p < 0.01
            n = 2;
        elseif p < 0.1
            n = 1;
        elseif p < 0.05 
            n = 1;
        else
            n = 0;
        end
    end
end
