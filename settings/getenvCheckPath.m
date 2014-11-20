function val = getenvCheckPath(key)
    val = getenvString(key);
    assert(exist(val, 'dir') > 0, 'Directory %s not found, from environment variable %s', val, key);
end