function h = colorView(map)
% map is nColors x 3 x nMaps

if isa(map, 'function_handle')
    map = map(20);
end
h = image(permute(map, [3 1 2]));
axis tight;
axis off

end