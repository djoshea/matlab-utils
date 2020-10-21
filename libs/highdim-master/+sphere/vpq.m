function v = vpq(p,q)

v = nchoosek(p+q-2,p-1) + nchoosek(p+q-2,p-1);
