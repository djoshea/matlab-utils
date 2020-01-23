function vec = lindeltathru(value, ind, delta, N)
% vec = lindeltathru(value, ind, delta, N)
% generate a vector with N elements where vec(i+1) - vec(i) == delta, and vec(ind) == value

from = value - (ind-1)*delta;
vec = lindelta(from, delta, N);

end