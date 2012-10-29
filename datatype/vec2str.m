function str = vec2str(vec)
% returns a string representation of a vector

str = ['[' num2str(makerow(vec)) ']'];

if size(vec, 1) > size(vec, 2)
    % include a transpose tick if its a column vector
    str = [str ''''];
end
