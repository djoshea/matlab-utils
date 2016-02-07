function MCD = GetData()

global MClustInstance
assert(isa(MClustInstance, 'MClust0'), 'MClust has entered an unknown state.');
assert(isvalid(MClustInstance.Data), 'MClust has entered an unknown state.');
MCD = MClustInstance.Data;
