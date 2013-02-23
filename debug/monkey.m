function monkey(n)

if nargin == 0
    n = 1;
end

for i = 1:n
    fprintf('\xF0\x9F\x90\xB5 ');
end
fprintf('\n');