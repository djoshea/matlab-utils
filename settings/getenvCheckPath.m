function val = getenvCheckPath(key)
    val = getenvString(key);
    assert(exist(val, 'dir') > 0 || exist(val, 'file') > 0, 'Directory / File %s not found, from environment variable %s', val, key);
end