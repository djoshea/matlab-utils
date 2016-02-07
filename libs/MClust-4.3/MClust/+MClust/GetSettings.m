function MCS = GetSettings()

global MClustInstance
assert(isa(MClustInstance, 'MClust0'));
assert(isvalid(MClustInstance.Settings));
MCS = MClustInstance.Settings;
