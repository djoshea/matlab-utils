
% this callback is attached by demopanelD

function demopanel_callback(data)

p = data.panel;
p
p.object
disp(['callback fired: object type was "' get(p.object, 'type') '"'])
disp(['panel position was "' num2str(p.position) '"'])


