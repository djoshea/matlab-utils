function val = getenvString(key)
    val = getenv(key);
    if isempty(val)
        error('Environment variable %s not found. Use setenv to create it.', key); 
    end
end