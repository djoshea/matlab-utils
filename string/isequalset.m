function tf = isequalset(c1, c2)
% returns true if cellstr c1 contains exactly the same strings as
% cellstr c2. It's equivalent to a sort-insensitive version of isequal

tf = isempty(setxor(c1, c2));