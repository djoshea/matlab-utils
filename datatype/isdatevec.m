function [tf vec] = isdatevec(s,fmat)
    % returns true if s is a string representation of a date
    if isempty(s) || ~ischar(s)
        tf = false;
        vec = nan(1,6);
        return;
    end
    
    try
        if nargin == 2 && ~isempty(fmat)
            vec = datevec(s,fmat);
        else 
            vec = datevec(s);
        end
        tf = true;
    catch
        vec = nan(1,6);
        tf = false;
    end
end

        
