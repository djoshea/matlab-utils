function tf = getenvBoolean(key, default)
    val = getenv(key);
    if isempty(val)
        if nargin < 2
            error('Environment variable %s not set', key);
        else
            tf = default;
            return;
        end
    end
    
    v = str2double(val);
    if v == 1
        tf = true;
    elseif v == 0
        tf = false;
    else
        error('Environment variable %s must be 0 or 1', key);
    end
end