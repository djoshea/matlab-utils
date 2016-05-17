function s = getPValueStr(p)
    if p < 0.0001
        s = 'p < 0.0001 ****';
    elseif p < 0.001
        s = 'p < 0.001 ***';
    elseif p < 0.01
        s = 'p < 0.01 **';
    elseif p < 0.05 
        s = 'p < 0.05 *';
    else
        s = sprintf('p > 0.05 [%.3f]', p);
    end
end
